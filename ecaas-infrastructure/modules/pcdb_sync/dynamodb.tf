
resource "aws_dynamodb_table" "products_table" {
  name         = "products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "technologyType"
    type = "S"
  }

  attribute {
    name = "technologyGroup"
    type = "S"
  }

  attribute {
    name = "brandName"
    type = "S"
  }

  global_secondary_index {
    name            = "by-technology-type"
    hash_key        = "technologyType"
    range_key       = "brandName"
    projection_type = "INCLUDE"
    non_key_attributes = [
      "id",
      "brandName",
      "modelName",
      "modelQualifier",
      "technologyType",
      "boilerLocation",
      "communityHeatNetworkName",
    ]
  }

  global_secondary_index {
    name            = "by-technology-group"
    hash_key        = "technologyGroup"
    range_key       = "brandName"
    projection_type = "INCLUDE"
    non_key_attributes = [
      "id",
      "brandName",
      "modelName",
      "modelQualifier",
      "technologyType",
      "boilerProductID",
      "vesselType"
    ]
  }
}

