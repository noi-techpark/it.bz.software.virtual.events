# Jitsi, Matrix/Element 

## Infrastructure Deployment
The TF efs module currently requires that the subnets are already created, otherwise the terraform plan/apply will fail.
- go into the root directory "it-bz-software-virtual-jitsi/"
- first do an tf init (currently the tf state is saved localy):

`terraform init`

- to deploy the subnets:

`terraform plan -target=module.networking --var-file=./config/staging.tfvars`

`terraform apply -target=module.networking --var-file=./config/staging.tfvars`

- to deploy all other resources:

`terraform plan --var-file=./config/staging.tfvars`

`terraform apply --var-file=./config/staging.tfvars`

- to destroy all resources again (you can destroy them all at once):

`terraform destroy --var-file=./config/staging.tfvars`

no manual steps are needed to be performed in the AWS console.

## PostgreSQL upgrade
First connect to the EC2 instance and created a DB dump:

`docker exec -it <postgres_container> /bin/bash`

`/usr/bin/pg_dump -U synapse synapse > /var/lib/postgresql/data/backups/synapse-backup.sql`

Make sure the backup is saved on the EFS mount.

Now in the main.tf file, add a comment at the beginning of the every line for the "ecs_task_definitions_matrix" module (currently line 335-355)

deploy the new resources:

`terraform plan --var-file=./config/staging.tfvars`

`terraform apply --var-file=./config/staging.tfvars`

this will stop the matrix/element application. Now you can move the old postgreSQL data to a backup folder:

```
# mount the efs if not already one
file_system_id_1=<fs_id>
efs_mount_point_1=/mnt/efs/fs
mkdir -p "${efs_mount_point_1}"
test -f "/sbin/mount.efs" && printf "\n${file_system_id_1}:/ ${efs_mount_point_1} efs tls,_netdev\n" >> /etc/fstab || printf "\n${file_system_id_1}.efs.eu-west-1.amazonaws.com:/ ${efs_mount_point_1} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0\n" >> /etc/fstab
test -f "/sbin/mount.efs" && grep -ozP 'client-info]\nsource' '/etc/amazon/efs/efs-utils.conf'; if [[ $? == 1 ]]; then printf "\n[client-info]\nsource=liw\n" >> /etc/amazon/efs/efs-utils.conf; fi;
retryCnt=15; waitTime=30; while true; do mount -a -t efs,nfs4 defaults; if [ $? = 0 ] || [ $retryCnt -lt 1 ]; then echo File system mounted successfully; break; fi; echo File system not available, retrying to mount.; ((retryCnt--)); sleep $waitTime; done;
```

```
# remove the old backup files if needed
mkdir -p /mnt/efs/fs/matrix/postgres_bak/data/
mv /mnt/efs/fs/matrix/postgres/data/* /mnt/efs/fs/matrix/postgres_bak/data/
```

Remove the comments for the "ecs_task_definitions_postgres_upgrade" module, also in the main.tf (currently line 310-332) and start a new TF deployment:

`terraform plan --var-file=./config/staging.tfvars`

`terraform apply --var-file=./config/staging.tfvars`

This will now start only a postgreSQL with the version defined in the "postgres_upgrade.tftpl" file.

Copy the backup file to the new created PostgreSQL data folder:

```
mkdir -p /mnt/efs/fs/matrix/postgres/data/backups/
cp /mnt/efs/fs/matrix/postgres_bak/data/backups/synapse-backup.sql /mnt/efs/fs/matrix/postgres/data/backups/
docker exec -it <postgres_container> /bin/bash
psql synapse < /var/lib/postgresql/data/backups/synapse-backup.sql
```

Change the comments in the main.tf back again and do the final deployment with the new PostgreSQL version:

`terraform plan --var-file=./config/staging.tfvars`

`terraform apply --var-file=./config/staging.tfvars`

## Element Upgrade

For the Element upgrade you need to do something similar as the postgreSQL upgrade. Stop the task in the ECS Console.
Connect to the host (make sure the EFS is mounted), move the "/mnt/efs/fs/matrix/element/" to a backup location and wait until ECS starts the task again (can take up to 10 min).

The new Element verison is now started, you only need to check the config.json for customization, or copy the old config.json from the backup location.

### ECS: 
Container Service and main part, currently 2 Clusters deployed:
Production: "jitsi-cluster" with type c5x.large
Staging: "jitsi-staging-cluster" with type c5a.large

Jitsi and Matrix is running on these clusters.

#### Cluster Features:
- Services: Jitsi and Matrix are running via service. Here you can define the task verion (see below for more details about tasks), launch type (should be EC2), cluster, ...
To deploy a new task version, update the corresponding service and select the right version under "Revision".

- Tasks: shows the current running tasks with some details. This tasks are started either manually, or in our case via service. In case of app issues, the tasks can be stopped and the service will automatically start new tasks (this can take up to 1min and no data is lost).

- ECS Instances: shows the running instances in the cluster

- Metrics: shows the overall cluster utilization

- scheduled tasks: not in use

- Tags: TBD

- capacity provider: shows the auto scaling possibility

#### Task Definition:
Contains all the configuration for the container deployment. Every new configuration/change creates a new version of this task.
A task contains container specific configuration (memory limit, volume, env. variables, ...) and task specific configurations (e.g. task memory usage, conatiners to run, volumes - efs to use by container, ...).

### Auto scaling group

Contains auto scaling behavious for prod and staging cluster. Currently only Prod. scales out at 75% CPU usage and scales in at 25%. Under "Instance management" the primary EC2 is scale in protected, so there is no service down during scale in actions.

Prod: amazon-ecs-cli-setup-jitsi-cluster-EcsInstanceAsg-1O8VE9KX1Q9YM
Staging: amazon-ecs-cli-setup-jitsi-cluster-staging-EcsInstanceAsg-2VGMNODF5M4G

### EFS: Storage

Persistance storage for jitsi and matrix (e.g. DB-, config-, ... files). 2 EFS currently in use for prod and staging:
Prod: jitsi-matrix-efs - fs-b61d8482
Staging: jitsi-matrix-efs-staging - fs-bce67e88

On the EFS there are subfolders for every matrix and jitsi component.

### ELB:
Application Loadbalancer with URL based forwarding

One for each environment. The ELB uses target groups (points to EC2 with a specific port) to route traffic with a specific URL to the right container (e.g. element.virtual.software.bz.it to EC2 port 8080)

Prod: jitsi-matrix-lb
Staging: jitsi-matrix-lb-staging

### Route53:

Contains all the needed C-Name records.

## Jitsi tipps and tricks

### Change/Hide the logo in Jitsi meetings

The Jitsi logo used as watermark in meetings is stored in the docker-container at /usr/share/jitsi-meet/images/watermark.svg.

To _hide the logo_, just rename it:

Log in to the EC2 instance and perform the following command:
<pre>cd /mnt/efs/fs1/jitsi/jitsi-meet/images/
mv watermark.svg watermark.svg_ba
</pre>

If the volume is not mounted, move the image inside of the container
<pre>docker exec -it "jitsi-meet-web" mv /usr/share/jitsi-meet/images/watermark.svg /usr/share/jitsi-meet/images/watermark.svg_ba</pre>

EFS mount command:
<pre>
yum install -y amazon-efs-utils
apt-get -y install amazon-efs-utils
yum install -y nfs-utils
apt-get -y install nfs-common
# replace the ID with the actual EFS ID
file_system_id_1=fs-123456
efs_mount_point_1=/mnt/efs/fs1
mkdir -p "${efs_mount_point_1}"
test -f "/sbin/mount.efs" && printf "\n${file_system_id_1}:/ ${efs_mount_point_1} efs tls,_netdev\n" >> /etc/fstab || printf "\n${file_system_id_1}.efs.eu-west-1.amazonaws.com:/ ${efs_mount_point_1} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0\n" >> /etc/fstab
test -f "/sbin/mount.efs" && grep -ozP 'client-info]\nsource' '/etc/amazon/efs/efs-utils.conf'; if [[ $? == 1 ]]; then printf "\n[client-info]\nsource=liw\n" >> /etc/amazon/efs/efs-utils.conf; fi;
retryCnt=15; waitTime=30; while true; do mount -a -t efs,nfs4 defaults; if [ $? = 0 ] || [ $retryCnt -lt 1 ]; then echo File system mounted successfully; break; fi; echo File system not available, retrying to mount.; ((retryCnt--)); sleep $waitTime; done;
</pre>

To _change the logo_, upload a new SVG file to the EC2 instance, name it "watermark.svg" and copy it into the folder `/mnt/efs/fs1/jitsi/jitsi-meet/images/`

Please note that the old image might still be cached in your browser, so you might not see the change immediately.

### Add accounts (e.g. for unlocking rooms)

Adding accounts to jitsi can at the moment only be done via commandline. The command needs to be executed in the prosody container. In order to get the ID of this container, log into the EC2 instanance and run 
<pre>
docker ps
</pre>
Copy the full name of the prosody container, it will look somewhat like this: _ecs-jitsi-meet-task-staging-5-prosody-bcf5e7c8bfd8b2f93b00_

Execute the following command (exchange the container name, user name and password accordingly):
<pre>
docker exec CONTAINER-NAME prosodyctl --config /config/prosody.cfg.lua register USERNAME meet.jitsi PASSWORD
</pre>

## Matrix/Element tipps and tricks

### Admin users

add admin user to Matrix/Elements. This is required to create communities:
<pre>docker exec -it postgres psql -U synapse synapse -c "update users set admin=1 where name='@username:matrix.virtual.software.bz.it';"</pre>


### Customisation

#### Welcome page background image

1. Upload a JPG (<1MB recommended) to the server.
2. In order to do any changes, you will need sudo permissions. Execute the following command to switch to the root user:
    `sudo bash`
3. Copy the image into the element theme background folder:

    `cp <PATH-TO-IMAGE>/element_background.jpg /mnt/efs/fs1/matrix/element/themes/element/img/backgrounds/`
4. Alter the element config in order to use the new image. Go into the element directory and open config.json with any editer (e.g. vim or nano)

    <pre>
    cd /mnt/efs/fs1/matrix/element
    nano config.json
    </pre>

5. In the JSON file, edit the "branding" section as followed. If the section does not exist yet, add it to the file.

    <pre>
    {
        ...
        "brand": "Element",
        "branding": {
            "welcomeBackgroundUrl": "themes/element/img/backgrounds/element_background.jpg"
        },
        ...
    }
    </pre>

6. In order to apply the changes, the synapse docker container needs to be restarted. There are 2 ways to to this:
    1. via the ECS dashboard
    2. directly on the VM, simply stop the corresponding container (`docker stop <CONTAINER-NAME>`), ECS will automatically restart it ASAP.

#### Rename Widgets

See [How to rename widgets](docs/How_to_rename_widgets.pdf).


