# events-jitsi
## Infrastructure
### ECS: 
Container Service and main part, currently 2 Clusters deployed:
Production: "jitsi-cluster" with type c5x.large
Staging: "jitsi-staging-cluster" with type c5a.large

Cluster Features:
- Services: Jitsi and Matrix are running via service. Here you can define the task verion (see below for more details about tasks), launch type (should be EC2), cluster, ...
To deploy a new task version, update the corresponding service and select the right version under "Revision".

- Tasks: shows the current running tasks with some details. This tasks are started either manually, or in our case via service. In case of app issues, the tasks can be stopped and the service will automatically start new tasks (this can take up to 1min and no data is lost).

- ECS Instances: shows the running instances in the cluster

- Metrics: shows the overall cluster utilization

- scheduled tasks: not in use

- Tags: TBD

- capacity provider: shows the auto scaling possibility

Task Definition:
Contains all the configuration for the container deployment. Every new configuration/change creates a new version of this task.
A task contains container specific configuration (memory limit, volume, env. variables, ...) and task specific configurations (e.g. task memory usage, conatiners to run, volumes - efs to use by container, ...).

### Auto scaling group

Contains auto scaling behavious for prod and staging cluster. Currently only Prod. scales out at 75% CPU usage and scales in at 25%. Under "Instance management" the primary EC2 is scale in protected, so there is no service down during scale in actions.

### EFS: Storage

Persistance storage for jitsi and matrix (e.g. DB-, config-, ... files). 2 EFS currently in use for prod and staging:
jitsi-matrix-efs - fs-b61d8482
jitsi-matrix-efs-staging - fs-bce67e88

On the EFS there are subfolders for every matrix and jitsi component.

### ELB:
Application Loadbalancer with URL based forwarding

One for each environment. The ELB uses target groups (points to EC2 with a specific port) to route traffic with a specific URL to the right container (e.g. element.virtual.software.bz.it to EC2 port 8080)

### Route53:

Contains all the needed C-Name records.

## Jitsi tipps and tricks

### Change/Hide the logo in Jitsi meetings

The Jitsi logo used as watermark in meetings is stored in the docker-container at /usr/share/jitsi-meet/images/watermark.svg. T

To _hide the logo_, just rename it:

* Log in to the EC2 instance and perform the following command:
* <pre>cd /mnt/efs/fs1/jitsi/jitsi-meet/images/
mv watermark.svg watermark.svg_ba
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
docker exec <CONTAINER-NAME> prosodyctl --config /config/prosody.cfg.lua register <USERNAME> meet.jitsi <PASSWORD>
</pre>
