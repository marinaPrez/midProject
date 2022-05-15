# create 3 consul servers :
###########################

resource "aws_instance" "consul_server" {
  count         		        = 3
  ami           		       	= lookup(var.ami, var.region)
  instance_type                         = "t2.micro"
  key_name                              = aws_key_pair.opsschool_consul_key.key_name
  #subnet_id                             = aws_subnet.public.id
  subnet_id                             = data.aws_subnets.pub_subnet.ids[0]
  iam_instance_profile                  = aws_iam_instance_profile.consul-join.name
  associate_public_ip_address           = true
  vpc_security_group_ids 		= [aws_security_group.opsschool_consul.id]


  provisioner "file" {
    source      = "scripts/consul-server.sh"
    destination = "/home/ubuntu/consul-server.sh"
    connection {   
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.pem_key_name)      
    }   
  }


   provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/consul-server.sh",
      "sudo /home/ubuntu/consul-server.sh",
         ]
    connection {
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.pem_key_name)
    }
  }


  tags = {
    Name = "opsschool-server_${count.index}"
    consul_server = "true"
    role = "consul server"
    environment = "production"
  }

}


#  create one consul agent
############################

resource "aws_instance" "consul_agent" {
  ami                               = lookup(var.ami, var.region)
  instance_type                     = "t2.micro"
  key_name                          = aws_key_pair.opsschool_consul_key.key_name
  #subnet_id                         = aws_subnet.public.id
  subnet_id                         = data.aws_subnets.pub_subnet.ids[0]
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids            = [aws_security_group.opsschool_consul.id]
  user_data       = <<EOF
#!bin/bash
sudo apt-get update
sudo apt-get install nginx -y
echo "OPSSCHOOL RULES ! " | sudo tee /usr/share/nginx/html/index.html
sudo systemctl start nginx
EOF
 
  provisioner "file" {
    source      = "scripts/consul-agent.sh"
    destination = "/home/ubuntu/consul-agent.sh"

    connection {   
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.pem_key_name)      
    }   
  }


   provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/consul-agent.sh",
      "sudo /home/ubuntu/consul-agent.sh &>> mylog.txt",
         ]
    connection {
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.pem_key_name)
    }
  }


  tags = {
    Name = "opsschool-agent"
    role = "ngnx"
    environment = "production"
    port = "80"
  }


}

output "servers" {
  value = ["${aws_instance.consul_server.*.public_ip}"]
}

output "agent" {
  value = aws_instance.consul_agent.public_ip
}
 
