package controllers

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gofiber/fiber/v2"
)

func GetUploadURL(c *fiber.Ctx) error {
	fileName := c.Query("file")
	if fileName == "" {
		return c.Status(400).JSON(fiber.Map{"error": "El nombre del archivo es requerido"})
	}

	// 1. Cargar configuración (usa automáticamente el IAM Instance Profile)
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Error al configurar AWS"})
	}

	// 2. Crear cliente de S3 y el Presigner
	s3Client := s3.NewFromConfig(cfg)
	presignClient := s3.NewPresignClient(s3Client)

	bucketName := "mubi-tribute-posters-george0308"
	key := fmt.Sprintf("posters/%d-%s", time.Now().Unix(), fileName) // Evitamos duplicados con un timestamp

	// 3. Generar la URL firmada para PUT
	presignedReq, err := presignClient.PresignPutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(key),
	}, s3.WithPresignExpires(15*time.Minute))

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "No se pudo generar la URL"})
	}

	// 4. Retornamos la URL para subir (PUT) y la URL final donde vivirá el poster (GET)
	return c.JSON(fiber.Map{
		"upload_url": presignedReq.URL,
		"public_url": fmt.Sprintf("https://%s.s3.amazonaws.com/%s", bucketName, key),
	})
}
