resource "aws_docdb_subnet_group" "default" {
  name       = ${var.env}-docdb-subnet-groups"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-docdb-subnet-groups" }
  )
}
