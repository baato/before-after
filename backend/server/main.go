package main

import (
	"log"

	"github.com/baato/before-after/api"
	"github.com/baato/before-after/util"
)

func main() {
	config, err := util.LoadConfig("../../")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}
	server := api.NewServer(&config)

	// Start listening for incoming chat messages
	server.Start(":8848")
}
