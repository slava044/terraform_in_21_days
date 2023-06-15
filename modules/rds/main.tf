resource "aws_db_subnet_group" "main" {
    name       = var.env_code
    subnet_ids = var.subnet_ids

    tags = {
       Name  = var.env_code
  }
}

resource "aws_security_group" "main" {
    name   = "${var.env_code}-rds"
    vpc_id = var.vpc_id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [var.source_security_group]
  }
}

resource "aws_db_instance" "main" {
    identifier              = var.env_code
    allocated_storage       = 10
    db_name                 = "mydb"
    engine                  = "mysql"
    instance_class          = "db.t3.micro"
    username                = "admin"
    password                = var.rds_password
    multi_az                = true
    backup_retention_period = 35
    backup_window           = "21:00-21:30"
    skip_final_snapshot     = true
    db_subnet_group_name    = aws_db_subnet_group.main.name
    vpc_security_group_ids  = [aws_security_group.main.id]
}
