variable "region" {
  type    = string
  default = "us-east-1"
}

variable "datadog_api_key" {
  type      = string
  sensitive = true
}