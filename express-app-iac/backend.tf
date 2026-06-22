terraform {
# Remote backend config template. When running, I used my own
# ... S3 bucket and DynamoDB table for state locking. You will need to create your own and update the values below.
    backend "s3" {
        bucket = "turbovets-test"
        key = "express-ts-app/terraform.tfstate"
        region = "us-east-1"
        encrypt = true
        use_lockfile = true
    }
}