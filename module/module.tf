module "ec2" {
  source = "../"
  ami = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  vpc_id = ""
  subnet_id = ""
  key_name = ""
  volume_size = ""
  delete_on_termination = "false"
}

output "ec2_public_ip" {
  value = <<EOF
        ssh -i "~/.ssh/id_rsa" ubuntu@${module.ec2.public_ip}
    EOF
}
