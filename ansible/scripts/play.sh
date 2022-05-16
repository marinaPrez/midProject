ansible-playbook main_playbook.yaml -i inventory_aws_ec2.yaml --private-key=~/.ssh/ops_keys_dir/opsschool_consul.pem
ansible-playbook jenkins_registration_playbook.yaml -i inventory_aws_ec2.yaml --private-key=~/.ssh/ops_keys_dir/jenkins_ec2_key


