resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-project-bucket-123456ahmeddiab"
    tags = {
        Name = "my_s3_bucket"
    }
}