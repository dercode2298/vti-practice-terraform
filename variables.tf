variable "vpc_name" {
  default = "hungnv-tf-vpc"
}
variable "cidrvpc" {
  default = "10.0.0.0/16"
}

variable "tag" {
  default = {

    Name = "hungnv-tf-vpc"
    Owner = "hungnv"
  }
}

variable "az_count" {
  default = 3
}