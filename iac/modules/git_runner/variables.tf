
variable "private_subnet_ids" {
  type = list(string)
  default = [
    "subnet-0ae8816626c004a1b",
    "subnet-02d7d4d2a27b86cf2"
  ]
}

variable "public_subnet_ids" {
  type = list(string)
  default = [
    "subnet-0906f1b218b7f6303",
    "subnet-002049de472c72025"
  ]
}
