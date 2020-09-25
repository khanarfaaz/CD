terraform {
  backend "s3" {
    bucket  = "cloud9-epl"
    key  = "terraform/state"
    region = "us-east-2"
#   access_key = "XXXXXXXXXXXXXXXXXXXXXX"
#   secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }
}

provider "aws" {
  region = "us-east-1"
}
data "aws_ami" "example" {
  most_recent      = true
  owners           = ["self"]
  filter {
    name   = "name"
    values = ["EPL-*"]
  }
}

resource "aws_instance" "EPL" {
  ami = data.aws_ami.example.id
  key_name = "EPL"
  instance_type = "t2.micro"

  tags = {
    Name = "EPL"
    Env = "Cloud"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > /etc/ansible/hosts"
  }
 
provisioner "remote-exec" {
    inline = [
     "touch /tmp/EPL"
     ]
 connection {
    type     = "ssh"
    user     = "ubuntu"
    insecure = "true"
    private_key = "${file("/tmp/EPL.pem")}"
    host     =  aws_instance.EPL.public_ip
  }
}
}

output "EPL-ip" {
  value = "${aws_instance.EPL.public_ip}"
}
