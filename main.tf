
provider "aws" {
  region                  = "${var.region}"
  profile                 = "${var.profile}"
}

data "tls_public_key" "local" {
  private_key_pem = "${file("~/.ssh/id_rsa")}"
}

data "http" "myipv4" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  ipv4 = "${chomp(data.http.myipv4.body)}"
  public_key = "${data.tls_public_key.local.public_key_openssh}"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${data.tls_public_key.local.public_key_openssh}"
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.ipv4}/32"] 
  }
}

resource "aws_instance" "sshserver" {
  ami = "${lookup(var.al2_ami, var.region)}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"  
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
}

output "connect" {
  value = "ssh ec2-user@${aws_instance.sshserver.public_dns}"

}
