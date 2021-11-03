# Jitsi, Matrix
## Infrastructure
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

## Matrix tipps and tricks

add admin user to Matrix/Elements. This is required to create communities:
<pre>docker exec -it postgres psql -U synapse synapse -c "update users set admin=1 where name='@username:matrix.virtual.software.bz.it';"</pre>
