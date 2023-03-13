data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "security_group" {
  name   = "${var.namespace}-${var.project}-${var.project_git_checkout}-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
