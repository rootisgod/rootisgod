---
categories: linux docker jenkins ubuntu
date: "2021-07-29T16:32:00Z"
title: Running A Jenkins Job On A Specific Node From A Docker Image
---

A bit of a clumsy title, but i'm learning Jenkins and it seems like doing the following is actually quite difficult to do... I essentially have an agent which has Docker installed, and a label of 'Docker' and 'Linux'. The labels are there so I can hopefully schedule any Docker type runs on it. As an example, say I want to run an Ansible playbook, I can have a Docker image with the pre-reqs ready to use in my job. This avoids me messing up the Jenkins agent itself with a lot of stuff that could break one day.

But, trying to do that in a declarative pipeline seemed trickier than I expected. Perhaps i'm still an uber noob at Jenkins, but it took ages to find out how to do this. The documentation is good but it seems to miss this crucial detail.

[https://www.jenkins.io/doc/book/pipeline/docker/]()

So, i'm skipping the whole part of creating the agent and labelling it etc... as that would take a while. But, once you have done that, this is what you need in the pipeline definition, especially the first few lines. Enjoy!

```text
pipeline {                           // We are using a declarative pipeline
    agent {                          // We want to use an agent/node
        docker {                     // We want to use docker for this
            image 'alpine'           // The docker image to run in
            label 'Docker && Linux'  // Use a node/agent with these labels
            args '-u root:sudo'      // Add this to be root in the container
        }
    }
    stages {                         // We want to define our job stages
        stage('Echo Hostname') {     // Just a name for this stage
            steps {                  // What we will run
                sh "hostname"        // Echo the hostname to show its a container
            }
        }
        stage('Echo pwd') {          // Just a name for this stage
            steps {                  // What we will run
                sh "pwd"             // Show our current folder
            }
        }
    }
}
```

You should get output like the below (my agent is called 'LinuxBuildAgent', and has a label of 'Docker' and 'Linux')

```text
Started by user rootisgod
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] node
Running on LinuxBuildAgent in /var/jenkins/workspace/PipelineTestWithDocker
[Pipeline] {
[Pipeline] isUnix
[Pipeline] sh
+ docker inspect -f . alpine
.
[Pipeline] withDockerContainer
LinuxBuildAgent does not seem to be running inside a container
$ docker run -t -d -u 0:0 -w /var/jenkins/workspace/PipelineTestWithDocker -v /var/jenkins/workspace/PipelineTestWithDocker:/var/jenkins/workspace/PipelineTestWithDocker:rw,z -v /var/jenkins/workspace/PipelineTestWithDocker@tmp:/var/jenkins/workspace/PipelineTestWithDocker@tmp:rw,z -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** alpine cat
$ docker top c2283cd92e3e7ccbf4dceebe34f8c51228e2c578aeff72e1c087a597f818de87 -eo pid,comm
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Echo Hostname)
[Pipeline] sh
+ hostname
c2283cd92e3e
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Echo pwd)
[Pipeline] sh
+ pwd
/var/jenkins/workspace/PipelineTestWithDocker
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
$ docker stop --time=1 c2283cd92e3e7ccbf4dceebe34f8c51228e2c578aeff72e1c087a597f818de87
$ docker rm -f c2283cd92e3e7ccbf4dceebe34f8c51228e2c578aeff72e1c087a597f818de87
[Pipeline] // withDockerContainer
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```
