# --- GRUPO DE SUBREDES PARA LA DB ---
# Le dice a RDS en qué "pedazos" de tu red privada puede vivir
resource "aws_db_subnet_group" "muvi_db_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_db_subnet.id,
    aws_subnet.private_db_subnet_2.id
  ]

  tags = { Name = "Muvi DB Subnet Group" }
}

# --- INSTANCIA DE BASE DE DATOS (Postgres) ---
resource "aws_db_instance" "postgres" {
  identifier        = "${var.project_name}-db"
  engine            = "postgres"
  engine_version    = "15" # Versión estable y moderna
  instance_class    = "db.t3.micro" # <--- CAPA GRATUITA
  allocated_storage = 20           # <--- CAPA GRATUITA (GB)
  storage_type      = "gp2"

  # Credenciales (vienen de tus variables seguras)
  db_name  = "streaming_db" # El mismo nombre que usaste en Docker
  username = var.db_username
  password = var.db_password

  # Ubicación y Seguridad
  db_subnet_group_name   = aws_db_subnet_group.muvi_db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  # Importante para que no sea publica
  publicly_accessible = false
  skip_final_snapshot = true # Para que el 'destroy' sea rápido y no cobre por backups

  tags = { Name = "Muvi-Postgres-RDS" }
}

# --- OUTPUT: Para saber a dónde conectarnos ---
output "db_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "La URL de la base de datos para poner en tu .env"
}