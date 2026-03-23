package main

import (
	dataebase "go-fiber-api/database"
	"go-fiber-api/models"

	"github.com/gofiber/fiber/v2"
)

func main() {
	dataebase.Connect()
	app := fiber.New()

	app.Get("/api/movies", func(c *fiber.Ctx) error {
		var movies []models.Movie
		dataebase.DB.Find(&movies)
		return c.JSON(movies)
	})

	app.Post("/api/movies", func(c *fiber.Ctx) error {
		movie := new(models.Movie)

		// Parsear el JSON del cuerpo de la petición
		if err := c.BodyParser(movie); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "JSON inválido"})
		}

		// Guardar en Postgres usando GORM
		if err := dataebase.DB.Create(&movie).Error; err != nil {
			return c.Status(500).JSON(fiber.Map{"error": "No se pudo guardar"})
		}

		return c.Status(201).JSON(movie)
	})

	app.Listen(":3000")
}
