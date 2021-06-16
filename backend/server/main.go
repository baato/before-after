package main

import (
	"log"
	"net/http"

	Websocket "./websocket"
	WorkerPool "./workerpool"
	"github.com/gorilla/websocket"
)

//specify number of concurrent workers and max queue size
var maxWorkers int = 1
var maxQueueSize int = 50

var jobQueue = make(chan WorkerPool.Job, maxQueueSize)

// Start the dispatcher.
var dispatcher = WorkerPool.NewDispatcher(jobQueue, maxWorkers)

var clients = make(map[*websocket.Conn]bool) // connected clients

// Configure the upgrader
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type server struct{}

func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	//Allow CORS here By * or specific origin
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	switch r.Method {
	case "GET":
		WorkerPool.RequestHandlerForAPI(r, jobQueue)

		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"success": true, "message": "Instance is being provisioned"}`))
	default:
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte(`{"message": "not found"}`))
	}
}

func main() {
	s := &server{}
	http.Handle("/api/v1/instance", s)

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
				WorkerPool.RequestHandlerForSocket(msg, ws, jobQueue)
			}

			if msg.Message == "keepalive" {
				Websocket.NotifyClient("pong", ws)
			}
		}
	})

	// Start listening for incoming chat messages
	log.Fatal(http.ListenAndServe(":8848", nil))
}
