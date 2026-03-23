resource "aws_s3_bucket" "muvi_posters" {
  bucket = "mubi-tribute-posters-george0308" 
}

# Permitir que las imágenes sean públicas (Lectura)
resource "aws_s3_bucket_public_access_block" "muvi_access" {
  bucket = aws_s3_bucket.muvi_posters.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.muvi_posters.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.muvi_posters.arn}/*"
      }
    ]
  })
}

# El Rol en sí
resource "aws_iam_role" "muvi_api_role" {
  name = "muvi-api-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# La política de permisos
resource "aws_iam_policy" "muvi_s3_policy" {
  name        = "MuviS3WritePolicy"
  description = "Permite subir posters al bucket de Mubi"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::mubi-tribute-posters-george0308",
          "arn:aws:s3:::mubi-tribute-posters-george0308/*"
        ]
      }
    ]
  })
}

# Adjuntar la política al rol
resource "aws_iam_role_policy_attachment" "muvi_attach" {
  role       = aws_iam_role.muvi_api_role.name
  policy_arn = aws_iam_policy.muvi_s3_policy.arn
}

resource "aws_iam_instance_profile" "muvi_profile" {
  name = "muvi-api-instance-profile"
  role = aws_iam_role.muvi_api_role.name
}