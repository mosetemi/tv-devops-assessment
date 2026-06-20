terraform {
# Remote backend config template. When running, I used my own
# ... S3 bucket and DynamoDB table for state locking. You will need to create your own and update the values below.
    backend "s3" {
        bucket = "[INSERT YOUR S3 BUCKET NAME HERE]"
        key = "express-ts-app/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "[INSERT YOUR DYNAMODB TABLE NAME HERE]"
        encrypt = true
    }
}