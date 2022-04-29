resource "aws_s3_bucket" "s3_state_bucket" {
  bucket = "terraform-bucket-opsschool"

  tags = {
    Name        = "s3 tf bucket"
  }
}

resource "aws_dynamodb_table" "terraform-locks" {
    name         = "terraform_dynamodb_oppschool"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
