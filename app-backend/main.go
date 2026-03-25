package main

import (
	"go-fiber-api/controllers"
	"go-fiber-api/database"
	"go-fiber-api/models"
	"os"

	"github.com/gofiber/fiber/v2"
)

func AuthMiddleware(c *fiber.Ctx) error {
	apiKey := c.Get("X-API-KEY")
	expectedKey := os.Getenv("ADMIN_API_KEY")

	// Protección extra: Si a ti se te olvida configurar la variable en el servidor
	if expectedKey == "" {
		return c.Status(500).JSON(fiber.Map{"error": "Error interno del servidor (Falta API Key)"})
	}

	if apiKey != expectedKey {
		return c.Status(401).JSON(fiber.Map{"error": "No autorizado. Solo el admin puede editar."})
	}

	return c.Next()
}

func main() {
	database.Connect()
	app := fiber.New()

	app.Get("/api/movies", func(c *fiber.Ctx) error {
		var movies []models.Movie
		database.DB.Find(&movies)
		return c.JSON(movies)
	})

	app.Post("/api/movies", AuthMiddleware, func(c *fiber.Ctx) error {
		movie := new(models.Movie)

		// Parsear el JSON del cuerpo de la petición
		if err := c.BodyParser(movie); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "JSON inválido"})
		}

		// Guardar en Postgres usando GORM
		if err := database.DB.Create(&movie).Error; err != nil {
			return c.Status(500).JSON(fiber.Map{"error": "No se pudo guardar"})
		}

		return c.Status(201).JSON(movie)
	})
	// --- MÉTODO PUT PARA EDITAR ---
	app.Put("/api/movies/:id", AuthMiddleware, func(c *fiber.Ctx) error {
		id := c.Params("id")
		var movie models.Movie

		// 1. Buscar si la película existe
		if err := database.DB.First(&movie, id).Error; err != nil {
			return c.Status(404).JSON(fiber.Map{"error": "Película no encontrada"})
		}

		// 2. Parsear los nuevos datos del Body al objeto 'movie'
		if err := c.BodyParser(&movie); err != nil {
			return c.Status(400).JSON(fiber.Map{"error": "JSON inválido"})
		}

		// 3. Guardar los cambios (GORM hace el UPDATE basado en la Primary Key)
		database.DB.Save(&movie)

		return c.JSON(movie)
	})
	// --- MÉTODO DELETE PARA ELIMINAR ---
	app.Delete("/api/movies/:id", AuthMiddleware, func(c *fiber.Ctx) error {
		id := c.Params("id")
		var movie models.Movie

		// 1. Verificar si la película existe antes de intentar borrarla
		if err := database.DB.First(&movie, id).Error; err != nil {
			return c.Status(404).JSON(fiber.Map{"error": "Película no encontrada"})
		}

		// 2. Borrar permanentemente del RDS
		if err := database.DB.Delete(&movie).Error; err != nil {
			return c.Status(500).JSON(fiber.Map{"error": "No se pudo eliminar de la base de datos"})
		}

		return c.Status(200).JSON(fiber.Map{"message": "Película eliminada con éxito"})
	})

	// Ejemplo de registro de ruta en Fiber
	app.Get("/api/upload-url", controllers.GetUploadURL)

	app.Listen(":3000")
}
