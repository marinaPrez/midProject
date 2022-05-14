output "vpc_id" {
  value       =  data.aws_vpc.vpc.id
}

output "full" {
value = data.aws_subnets.pub_subnet

}


output "public_subnets"{
  value  =  data.aws_subnets.pub_subnet.*.ids[0]
}
