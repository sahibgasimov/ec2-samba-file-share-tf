provider "aws" {
  region = var.region
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"
  name          = "samba-file-share"
  instance_type = var.instance_type
  ami           = var.ami
  vpc_security_group_ids = [aws_security_group.samba_file_share.id]
  subnet_id = var.subnet_id
  key_name = var.key_name
  user_data = <<-EOF
    #!/bin/bash

    apt-get update -y
    apt-get install samba -y

    groupadd share_users
    useradd --groups share_users --password mypass --user-group --no-create-home --shell /usr/sbin/nologin test
    smbpasswd -a test

    echo "[share]
    path = /datastore/share
    valid users = @share_users
    writable = yes
    browseable = yes
    read only = no
    create mask = 0770
    directory mask = 0770
    guest ok = no
    force group = share_users
    #win creates garbage files, so we are adding additional conf to hide all unnecessary thumbnails
    hide files = /\$RECYCLE.BIN/System Volume Information/desktop.ini/thumbs.db/" >> /etc/samba/smb.conf

    echo "[test]
    path = /datastore/test
    valid users = test
    writable = yes
    browseable = yes
    read only = no
    create mask = 0770
    directory mask = 0770
    guest ok = no
    force group = share_users
    hide files = /\$RECYCLE.BIN/System Volume Information/desktop.ini/thumbs.db/" >> /etc/samba/smb.conf

    mkdir -p /datastore/test
    mkdir -p /datastore/share
    
    apt install acl -y
    cd /datastore/
    setfacl -b -R test/
    chmod 770 -R test/
    chmod 770 -R share/
    chown -R test:share_users share/
    chown -R test:share_users test/

    systemctl restart smbd
    systemctl restart nmbd
    ufw allow 'Samba'
  EOF

  ebs_block_device = [
    {
      device_name           = "/dev/sda1"
      volume_type           = "gp2"
      volume_size           = var.volume_size
      delete_on_termination = var.delete_on_termination
    },
  ]

  tags = {
    Name = "samba-file-share"
  }
}

resource "aws_key_pair" "samba" {
  key_name   = var.key_name
  public_key = file("~/.ssh/id_rsa.pub")
  }

resource "aws_security_group" "samba_file_share" {
  name_prefix = "samba-file-share-"

  ingress {
    from_port   = 139
    to_port     = 139
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
value = module.ec2_instance.public_ip
}

