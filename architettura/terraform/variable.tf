//credential Variable
variable "access_key" {
  type    = string
  default = "access_key"

}

variable "secret_key" {
  type    = string
  default = "secret_key"
}

// network variable 

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16" #CIDR declaration for VPC
}

variable "subnets_cidr_Private" {
  type    = list(any)
  default = ["10.0.32.0/20", "10.0.16.0/20"] #CIDR declaration for 2 subnets 
}


variable "subnets_cidr_Pubblic" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.0.0/24"] #CIDR declaration for 2 subnets 
}

variable "availability_zones" {

  type    = list(any)
  default = ["eu-west-1a", "eu-west-1b"] #defining AZs for Subnets

}


// istance variable 
variable "instance_type_bastianHost" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "my_ssh_key_bastiahost"
}

variable "key_name_lunchconfig" {
  type    = string
  default = "my_ssh_key_lunchconfig"
}

variable "type_balancing" {
  type    = string
  default = "application"
}

variable "instance_type_tamplate_ami" {
  type    = string
  default = "t2.micro"
}

variable "user_ssh" {
  type    = string
  default = "ec2-user"
}

variable "interva_time" {
  type    = number
  default = 5
}

variable "timeout_tg" {
  type    = number
  default = 4
}

variable "unhealthy_threshold_tg" {
  type    = number
  default = 2
}

variable "status_code_sg" {
  type    = number
  default = 200
}