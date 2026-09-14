resource "aws_instance" "web_server" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data = <<-EOF
            #!/bin/bash
            apt-get update -y
            apt-get install -y apache2
            systemctl enable apache2
            systemctl start apache2
            echo "<h1>CloudOps Enterprise Platform</h1>" > /var/www/html/index.html
            echo "<p>Web Server deployed using Terraform</p>" >> /var/www/html/index.html
            EOF
  tags = {
    Name = "CloudOps-Web-Server"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "cloudops-web-sg"
  description = "Allow HTTP traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "SSH from EC2 Instance Connect"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = ["pl-0fa83cebf909345ca"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CloudOps-Web-SG"
  }
}

resource "aws_s3_bucket" "cloudops_storage" {
  bucket = "cloudops-enterprise-storage-saroj-2026"

  tags = {
    Name = "CloudOps Enterprise Storage"
  }
}

resource "aws_s3_bucket_versioning" "cloudops_storage_versioning" {
  bucket = aws_s3_bucket.cloudops_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudops_storage_lifecycle" {
  bucket = aws_s3_bucket.cloudops_storage.id

  rule {
    id     = "cloudops-lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudops_storage_encryption" {
  bucket = aws_s3_bucket.cloudops_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}