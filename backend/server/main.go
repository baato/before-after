package main

import (
	"database/sql"
	"log"

	"github.com/baato/before-after/api"
	db "github.com/baato/before-after/db/sqlc"
	"github.com/baato/before-after/util"
)

func main() {
	config, err := util.LoadConfig("../../")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	conn, err := sql.Open(config.DBDriver, config.DBSource)
	if err != nil {
		log.Fatalf("cannot connect to db:%v", err)
	}
	query := db.New(conn)

	server := api.NewServer(query, &config)

	// Start listening for incoming chat messages
	server.Start(":8848")
}
