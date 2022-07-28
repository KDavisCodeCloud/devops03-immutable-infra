provider "aws" {
  
  profile = var.profile
  region = "us-east-1"
}

resource "aws_db_instance" "db_instance" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  name                 = "contact_info_db"
  username             = "prostgres"
  password             = var.password
  security_group_ids = [sg-05f55b7e390abda20]
  publicly_publicly_accessible = true
}