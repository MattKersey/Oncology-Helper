package main

import (
	"log"
	"net/http"

	"github.com/MattKersey/go_backend/handlers"
)

func main() {
	http.HandleFunc("/appointment/", handlers.AppointmentHandler)
	http.HandleFunc("/question/", handlers.QuestionHandler)
	http.HandleFunc("/recording/", handlers.RecordingHandler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
