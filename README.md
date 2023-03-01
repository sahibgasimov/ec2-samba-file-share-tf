Working on a small lab project I had to come out with the resource to be able share files between small group of people. In this article, I'll show you how to use Terraform to create a Linux machine that functions as a file share, to be accessible from my Windows 10 client. The script I used for samba, automates the process and makes it easy to get up and running quickly.

module "ec2-instance" {
  source  = "github.com/sahibgasimov/ec2-samba-file-share.git"
  # insert the 5 required variables here


  ami = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  vpc_id = ""
  subnet_id = ""
  key_name = "samba-file-share"
  volume_size = "30"
  delete_on_termination = "false"
}

output "ec2_public_ip" {
  value = <<EOF
        ssh -i "~/.ssh/id_rsa" ubuntu@${module.ec2.public_ip}
    EOF
