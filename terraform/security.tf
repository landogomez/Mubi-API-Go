# --- GRUPO DE SEGURIDAD PARA LA API
resource "aws_security_group" "api_sg" {
  name        = "${var.project_name}-api-sg"
  description = "Permite trafico HTTP para la API"
  vpc_id      = aws_vpc.main_vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Esto permite que entres desde cualquier IP
  }

  # Entrada: Permitir puerto 3000 desde cualquier lugar (Internet)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: Permitir que la API hable con cualquier lugar (para bajar librerias o conectar a la DB)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "api-security-group" }
}

# --- GRUPO DE SEGURIDAD PARA EL RDS
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Permite trafico solo desde la API"
  vpc_id      = aws_vpc.main_vpc.id

  # Entrada: SOLO permite el puerto 5432 desde el Security Group de la API
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id] # <-- LA LLAVE MAESTRA
  }

  # Salida: Generalmente el DB no inicia conexiones, pero dejamos salida abierta por mantenimiento
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "db-security-group" }
}