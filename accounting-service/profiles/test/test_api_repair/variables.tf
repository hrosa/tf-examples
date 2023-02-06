# API
variable "api-name" {
  type = string
}

variable "api-version" {
  type = string
  default = "1.0.0"
}

variable "api-description" {
  type = string
  default = "My API"
}

variable "api-authorizer" {
  type = string
}