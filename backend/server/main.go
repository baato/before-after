package main

import (
	"github.com/baato/before-after/api"
)

func main() {
	server := api.NewServer()

	// Start listening for incoming chat messages
	server.Start(":8848")
}
