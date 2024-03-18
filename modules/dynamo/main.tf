resource "aws_dynamodb_table" "db" {
  billing_mode = "PAY_PER_REQUEST"
  name = var.table_name
  hash_key = var.hash_key.name
  attribute {
    name = var.hash_key.name
    type = var.hash_key.type
  }
}