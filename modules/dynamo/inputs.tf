variable "table_name" {
  type = string
}

variable "hash_key" {
  type = object({
    type = string
    name = string
  })
}