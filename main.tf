provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "http" "myipv4" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  ipv4 = "${chomp(data.http.myipv4.body)}"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file(var.local_public_key_file)}"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sshserver" {
  ami                    = "${lookup(var.al2_ami, var.region)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]

  provisioner "remote-exec" {
    inline = ["echo 'Waiting for shh to be available'"]

    connection {
      type        = "ssh"
      user        = "${var.username}"
      private_key = "${file(var.local_private_key_file)}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.username} -i '${aws_instance.sshserver.public_ip},'  ./ansible/helloworld.yml"
  }
}
