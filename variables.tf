variable "region" {
  default = "eu-west-3"
}
variable "profile" {
  default = "terraform"
}
variable "al2_ami" {
  type = "map"
  default = {
    "eu-west-3" = "ami-0451ae4fd8dd178f7"
  }
}

