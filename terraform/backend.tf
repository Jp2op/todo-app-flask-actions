terraform {
  backend "s3" {
    bucket         = "todo-flask-tf-backend"
    key            = "eks/flask-todo-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true                
  }
}