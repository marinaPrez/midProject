#!/bin/bash


Jenkins_server="34.219.162.213"
jenkins_agent="35.167.122.247"


# run on jenkins Server:
echo 'download jenkins-cli.jar'
ssh -i jenkins_ec2_key  ubuntu@$Jenkins_server "curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar"

echo 'installing plugins'
ssh -i jenkins_ec2_key  ubuntu@$Jenkins_server "echo 'installing plugins'; java -jar jenkins-cli.jar -s http://localhost:8080/ -webSocket install-plugin Git GitHub github-branch-source  pipeline-model-extensions build-monitor-plugin docker-workflow Swarm -deploy"



# run on node:

echo "download node client"
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "curl http://$Jenkins_server:8080/swarm/swarm-client.jar -o swarm-client.jar"

echo "connect node to Jenkins Server"
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "java -jar swarm-client.jar -url http://$Jenkins_server:8080 -webSocket -name node1 -disableClientsUniqueId &"
~
~
~
