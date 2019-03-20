variable "region" {
  default = "eu-west-3"
}

variable "profile" {
  default = "terraform"
}

variable "local_public_key_file" {
  default = "~/.ssh/id_rsa.pub"
}
variable "local_private_key_file" {
  default = "~/.ssh/id_rsa"
}
variable "username" {
  default = "ec2-user"
}

variable "al2_ami" {
  type = "map"

  default = {
    "eu-west-3" = "ami-0451ae4fd8dd178f7"
  }
}
