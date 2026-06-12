package main

import (
	"embed"
	"errors"
	"log"
	"net/http"
	"os"
)

//go:embed index.html styles.css script.js assets/*
var website embed.FS

func handler() http.Handler {
	return http.FileServerFS(website)
}

func main() {
	address := os.Getenv("WEBSITE_ADDR")
	if address == "" {
		address = ":3000"
	}

	server := &http.Server{
		Addr:    address,
		Handler: handler(),
	}

	log.Printf("website listening on http://localhost%s", server.Addr)
	if err := server.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
		log.Fatal(err)
	}
}
