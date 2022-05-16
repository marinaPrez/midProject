#!/bin/bash


Jenkins_server="34.221.166.125"
jenkins_agent="54.189.130.80"

# run on server 

echo "Configiring jenkins Server:"
echo "##########################"
echo 'download jenkins-cli.jar'
ssh -i jenkins_ec2_key  ubuntu@$Jenkins_server "curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar"

echo 'installing plugins'
ssh -i jenkins_ec2_key  ubuntu@$Jenkins_server "echo 'installing plugins'; java -jar jenkins-cli.jar -s http://localhost:8080/ -webSocket install-plugin Git GitHub github-branch-source  pipeline-model-extensions build-monitor-plugin pipeline-build-step docker-workflow Swarm -deploy"



# run on node:
echo "Configiring jenkins Server:"
echo "##########################"
echo "download node client"
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "curl http://$Jenkins_server:8080/swarm/swarm-client.jar -o swarm-client.jar"

echo "install cubectl"
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "sudo snap install kubectl --classic"
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "aws eks --region=us-west-2 update-kubeconfig --name mid-project-eks-cluster"

echo "install aws cli"
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip "
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "unzip awscliv2.zip"
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "sudo ./aws/install"


echo "connect node to Jenkins Server"
ssh -i jenkins_ec2_key  ubuntu@$jenkins_agent "nohup java -jar swarm-client.jar -url http://$Jenkins_server:8080 -webSocket -name node1 -disableClientsUniqueId &"

~
~
