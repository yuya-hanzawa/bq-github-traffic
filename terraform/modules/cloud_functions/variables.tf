variable "script_dir" {
  type = string
}

variable "zip_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "gcf_name" {
  type = string
}

variable "memory" {
  type    = number
  default = 256
}

variable "timeout" {
  type    = number
  default = 60
}

variable "region" {
  type    = string
  default = "us-central1"
}
