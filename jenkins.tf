locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}


resource "aws_security_group" "jenkins" {
  name = local.jenkins_default_name
  vpc_id      = aws_vpc.oppschool_vpc.id
  description = "Allow Jenkins inbound traffic"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port = 0
    to_port = 0
    // -1 means all
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = local.jenkins_default_name
  }
}

resource "aws_key_pair" "jenkins_ec2_key" {
  key_name = "jenkins_ec2_key"
  public_key = file("jenkins_ec2_key.pub")
}

resource "aws_instance" "jenkins_server" {
  ami = "ami-0cb4e786f15603b0d"
  instance_type = "t2.micro"
  key_name = aws_key_pair.jenkins_ec2_key.key_name
  subnet_id                = aws_subnet.public.*.id[0]
  tags = {Name = "Jenkins Server"}
  associate_public_ip_address = true
  #security_groups = [ aws_security_group.jenkins.name ]
  vpc_security_group_ids = [aws_security_group.jenkins.id]

 provisioner "file" {
    source      = "scripts/configure_jenkins.sh"
    destination = "/home/ubuntu/configure_jenkins.sh"
    connection {
      host        = aws_instance.jenkins_server.public_ip
      user        = "ubuntu"
      private_key = file("jenkins_ec2_key")
    }
  }


 connection {
    host = aws_instance.jenkins_server.public_ip
    user = "ubuntu"
    private_key = file("jenkins_ec2_key")
  }



  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install docker.io  -y",
      "sudo systemctl start docker",
      "sudo apt install openjdk-11-jre-headless -y",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R 1000:1000 ${local.jenkins_home}"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
    ]
  }

   provisioner "remote-exec" {
    inline = [
       "echo whoami"
       #"curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar",
#      "echo 'installing plugins'; java -jar jenkins-cli.jar -s http://localhost:8080/ -webSocket install-plugin Git GitHub github-branch-source  pipeline-model-extensions build-monitor-plugin docker-workflow Swarm -deploy"
    ]
  }

}


resource "aws_instance" "jenkins_node" {
  ami = "ami-0cb4e786f15603b0d"
  instance_type = "t2.micro"
  key_name = aws_key_pair.jenkins_ec2_key.key_name
  subnet_id                = aws_subnet.public.*.id[0]
  tags = {Name = "Jenkins Node"}
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins.id]

 connection {
    host = aws_instance.jenkins_node.public_ip
    user = "ubuntu"
    private_key = file("jenkins_ec2_key")
  }

  provisioner "remote-exec" {

    inline = [
      "sudo apt-get update -y",
      "sudo apt install docker.io git -y",
      "sudo systemctl start docker",
      "sudo apt install openjdk-11-jre-headless -y",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R 1000:1000 ${local.jenkins_home}",
     # "curl http://${aws_instance.jenkins_server.public_ip}:8080/swarm/swarm-client.jar -o swarm-client.jar",
     # "java -jar swarm-client.jar -url http://${aws_instance.jenkins_server.public_ip}:8080 -webSocket -name node1 -disableClientsUniqueId"
    ]
  }
}


output "Jenkins_server" {
  value = aws_instance.jenkins_server.public_ip
}

output "jenkins_agent" {
  value = aws_instance.jenkins_node.public_ip
}
