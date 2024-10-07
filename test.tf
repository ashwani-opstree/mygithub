provider "aws" {
  region = "us-west-2"
}

# IAM Role for EC2 to interact with SSM
resource "aws_iam_role" "ec2_role" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach SSM permissions for the EC2 instance
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 instance that will receive the file
resource "aws_instance" "example" {
  ami           = "ami-12345678"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "ExampleInstance"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Replace with your Base64 encoded content
locals {
  base64_content = file("path/to/local/binary_file.b64")  # Path to your Base64 file
}

# Create an SSM document to write file content to the EC2 instance
resource "aws_ssm_document" "ssm_upload_binary" {
  name          = "uploadBinaryFile"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Write base64 encoded binary to EC2 instance and decode it",
    mainSteps     = [{
      action      = "aws:runShellScript",
      name        = "writeBinary",
      inputs      = {
        runCommand = [
          <<-EOT
          #!/bin/bash
          echo "${local.base64_content}" > /home/ec2-user/binary_file.b64
          base64 -d /home/ec2-user/binary_file.b64 > /home/ec2-user/binary_file
          chmod +x /home/ec2-user/binary_file  # If it's an executable binary
          EOT
        ]
      }
    }]
  })
}

# Execute the SSM document to upload the binary file
resource "aws_ssm_command" "ssm_run_command" {
  document_name = aws_ssm_document.ssm_upload_binary.name
  instance_ids  = [aws_instance.example.id]
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
