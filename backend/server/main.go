package main

import (
	"log"
	"net/http"

	Websocket "./websocket"
	WorkerPool "./workerpool"
	"github.com/gorilla/websocket"
)

var clients = make(map[*websocket.Conn]bool) // connected clients

// Configure the upgrader
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func main() {
	//specify number of concurrent workers and max queue size
	var maxWorkers int = 1
	var maxQueueSize int = 50

	// Create the job queue.
	jobQueue := make(chan WorkerPool.Job, maxQueueSize)

	// Start the dispatcher.
	dispatcher := WorkerPool.NewDispatcher(jobQueue, maxWorkers)
	dispatcher.Run()

	// Configure websocket route
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		ws, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			log.Fatal(err)
		}

		// Make sure we close the connection when the function returns
		defer ws.Close()

		// register client
		clients[ws] = true

		for {
			var msg Websocket.Message
			// Read in a new message as JSON and map it to a Message object
			err := ws.ReadJSON(&msg)
			if err != nil {
				log.Printf("error: %v", err)
				delete(clients, ws)
				break
			}
			if msg.Message == "provision" {
				WorkerPool.RequestHandler(msg, ws, jobQueue)
			}

			if msg.Message == "keepalive" {
				Websocket.NotifyClient("pong", ws)
			}
		}
	})

	// Start listening for incoming chat messages
	log.Fatal(http.ListenAndServe(":8848", nil))
}
