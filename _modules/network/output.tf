output "vpc_id" {
  value = aws_vpc.hungnv-vpc.id
}

//export the public subnet id
output "public_subnet_id" {
  value = data.aws_subnets.public.ids
}

output "private_subnet_id" {
  value = data.aws_subnets.private.ids
  
}