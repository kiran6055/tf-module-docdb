#creating subnetgroup for DB
resource "aws_docdb_subnet_group" "default" {
  name        = "${var.env}-docdb-subnet-groups"
  subnet_ids  = var.subnet_ids

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

# creating Docdb (mongoDB) cluster with user and password which is already stored in aws system stroage parameter store coded is given in ansible-roboshop aws-parameter.yml

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.env}-docdb-cluster"
  engine                  = "docdb"
  engine_version          = var.engine_version
  master_username         = data.aws_ssm_parameter.DB_ADMIN_USER.value
  master_password         = data.aws_ssm_parameter.DB_ADMIN_PASS.value
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_docdb_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.docdb.id]
  storage_encrypted       = true
  #kms_key_id             = data.aws_kms_key.key.arn


  tags = merge(
    local.common_tags,
    { Name = "${var.env}-docdb-cluster" }
  )

}

# creating docdb node instances
resource "aws_docdb_cluster_instance" "cluster_instances" {
  count                   = var.number_of_instances
  identifier              = "${var.env}-docdb-cluster-instances-${count.index+1}"
  cluster_identifier      = aws_docdb_cluster.docdb.id
  instance_class          = var.instance_class
  #storage_encrypted      = true
  #kms_key_id             = data.aws_kms_key.key.arn


  tags = merge(
  local.common_tags,
  { Name = "${var.env}-docdb-cluster-instances-${count.index+1}" }
)
}

# creating aws ssm parameter of catalogue for DOCUMENTDB URL
resource "aws_ssm_parameter" "docdb_url_catalogue" {
  name  = "${var.env}.catalogue.DOCDB_URL"
  type  = "String"
  value = "mongodb://${data.aws_ssm_parameter.DB_ADMIN_USER.value}:${data.aws_ssm_parameter.DB_ADMIN_PASS.value}@${aws_docdb_cluster.docdb.endpoint}:27017/catalogue?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

# creating aws ssm parameter user for DOCUMENTDB URL
resource "aws_ssm_parameter" "docdb_url_user" {
  name  = "${var.env}.user.DOCDB_URL"
  type  = "String"
  value = "mongodb://${data.aws_ssm_parameter.DB_ADMIN_USER.value}:${data.aws_ssm_parameter.DB_ADMIN_PASS.value}@${aws_docdb_cluster.docdb.endpoint}:27017/users?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

# creating aws ssm parameter user for docdb for running and adding schemaload which is given in app main

resource "aws_ssm_parameter" "docdb_url" {
  name  = "${var.env}.docdb.DOCDB_URL"
  type  = "String"
  value = aws_docdb_cluster.docdb.endpoint
}

output "default" {
  value = aws_docdb_subnet_group.default
}