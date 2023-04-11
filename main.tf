#creating subnetgroup for DB
resource "aws_docdb_subnet_group" "default" {
  name       = "${var.env}-docdb-subnet-groups"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-docdb-subnet-groups" }
  )
}

# creating security group for DB
resource "aws_security_group" "docdb" {
  name        = "${var.env}-docdb-securitygroup"
  description = "${var.env}-docdb-securitygroup"
  vpc_id      = var.vpc_id

  ingress {
    description      = "mongodb"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-docdb-subnet-groups" }
  )

}