variable "environment" {
  description = "The environment name"
  type = object({
    key  = string
    name = string
  })
}

variable "billing_mode" {
  default     = "PAY_PER_REQUEST"
  description = "Controls how you are charged for read and write throughput and how you manage capacity"
  type        = string
}
