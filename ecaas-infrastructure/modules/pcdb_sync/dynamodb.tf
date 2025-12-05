
resource "aws_dynamodb_table" "products_table" {
  name = "products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
	name = "id"
	type = "N"
  }

  attribute {
	name = "category"
	type = "S"
  }

  attribute {
	name = "technologyType"
	type = "S"
  }

  attribute {
	name = "modelQualifier"
	type = "S"
  }

  attribute {
	name = "sk-by-brand"
	type = "S"
  }

  attribute {
	name = "sk-by-model"
	type = "S"
  }

  global_secondary_index {
	name = "by-category"
	hash_key = "category"
	projection_type = "INCLUDE"
	non_key_attributes = ["id", "brandName", "modelName", "modelQualifier"]
  }

  global_secondary_index {
	name = "by-brand"
	hash_key = "technologyType"
	range_key = "sk-by-brand"
	projection_type = "INCLUDE"
	non_key_attributes = ["id", "brandName", "modelName", "modelQualifier"]
  }

  global_secondary_index {
	name = "by-model"
	hash_key = "technologyType"
	range_key = "sk-by-model"
	projection_type = "INCLUDE"
	non_key_attributes = ["id", "brandName", "modelName", "modelQualifier"]
  }

  global_secondary_index {
	name = "by-model-qualifier"
	hash_key = "technologyType"
	range_key = "modelQualifier"
	projection_type = "INCLUDE"
	non_key_attributes = ["id", "brandName", "modelName", "modelQualifier"]
  }
}

