package utils

import (
	"context"
	"fmt"
	"mime/multipart"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func UploadToS3(file *multipart.FileHeader) (string, error) {
	// 1. Cargar configuración (usa el Rol de la EC2 automáticamente)
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	if err != nil {
		return "", err
	}

	client := s3.NewFromConfig(cfg)
	bucketName := "mubi-tribute-posters-george0308"

	// 2. Abrir el archivo
	f, err := file.Open()
	if err != nil {
		return "", err
	}
	defer f.Close()

	// 3. Subir a S3
	_, err = client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(file.Filename), // Nombre del archivo en el bucket
		Body:   f,
	})

	if err != nil {
		return "", err
	}

	// 4. Retornar la URL pública
	return fmt.Sprintf("https://%s.s3.amazonaws.com/%s", bucketName, file.Filename), nil
}
