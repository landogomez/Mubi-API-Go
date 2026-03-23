# 1. Buscar la imagen de Ubuntu más reciente automáticamente
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID de Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 2. Crear la instancia EC2 para la API
resource "aws_instance" "api_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Capa gratuita
  
  # La ponemos en la subred pública que ya creamos
  subnet_id                   = aws_subnet.public_api_subnet.id
  vpc_security_group_ids      = [aws_security_group.api_sg.id]
  associate_public_ip_address = true

  key_name = "muvi-key"

  # Script de inicio (User Data) para instalar Go y Docker de una vez
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF

  tags = {
    Name = "${var.project_name}-api-server"
  }
}

# 3. Output para saber la IP de tu servidor
output "api_public_ip" {
  value = aws_instance.api_server.public_ip
}