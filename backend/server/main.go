package main

import (
	"log"
	"os"
	"time"

	"github.com/baato/before-after/api"
	"github.com/getsentry/sentry-go"
)

func main() {
	// Initialize Sentry
	err := sentry.Init(sentry.ClientOptions{
		Dsn: os.Getenv("SENTRY_DSN"),
		// Enable printing of SDK debug messages.
		// Useful when getting started or trying to figure something out.
		Debug: true,
	})
	if err != nil {
		log.Fatalf("sentry.Init: %s", err)
	}
	// Flush buffered events before the program terminates.
	// Set the timeout to the maximum duration the program can afford to wait.
	defer sentry.Flush(2 * time.Second)

	server := api.NewServer()

	// Start listening for incoming chat messages
	server.Start(":8848")
}
