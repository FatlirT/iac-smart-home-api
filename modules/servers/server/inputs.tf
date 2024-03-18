variable "name" {
  type = string
}

variable "type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "inbound_ssh_permissions" {
  type = object({
    key_name = string
    sg_id = string
  })
  validation {
    condition     = var.inbound_ssh_permissions.key_name != null && var.inbound_ssh_permissions.sg_id != null
    error_message = "Both 'key_name' and 'sg_id' are required attributes."
  }
}

variable "app_source" {
  type = string
  default = null
}

variable "ip_name" {
  type = string
  default = null
}