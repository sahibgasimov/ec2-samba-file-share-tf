variable "ami" {
    default = "ami-0557a15b87f6559cf"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "region" {
    default = "us-east-1"
}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name"  {}
variable "volume_size"  {}
variable "delete_on_termination"  {}
#variable "security_group" {
#    default = module.security_group.id
#}
