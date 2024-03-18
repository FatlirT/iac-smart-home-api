variable "vpc_cidr_range" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "app_info" {
  type = object({
    name = string
    microservices = map(map(object({
      # hc_path   = string
      # aux_paths = list(object({
      #   method = string
      #   path   = string
      # }))
    })))
  })
}