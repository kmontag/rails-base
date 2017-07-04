resource "aws_security_group" "db" {
  vpc_id = "${var.vpc_id}"
  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["${var.vpc_cidr}"]
  }
}

resource "aws_db_subnet_group" "default" {
  name = "${var.name}"
  subnet_ids = ["${var.subnet_ids}"]
}

resource "aws_db_instance" "default" {
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"

  allocated_storage      = 5
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  name                   = "${var.name}"

  username               = "${var.username}"
  password               = "${var.password}"

  publicly_accessible    = false
}
