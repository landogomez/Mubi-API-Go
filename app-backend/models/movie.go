package models

import "gorm.io/gorm"

type Movie struct {
	gorm.Model
	Title      string `json:"title" gorm:"not null;index"`
	Director   string `json:"director" gorm:"not null"`
	Year       int    `json:"year"`
	Summary    string `json:"summary" gorm:"type:text"`
	PosterURL  string `json:"poster_url"`
	IsFeatured bool   `json:"is_featured" gorm:"default:false"`
}
