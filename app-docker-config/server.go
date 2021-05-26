package main

import (
    "log"
    "net/http"
	"os/exec"
	"fmt"
	"github.com/gorilla/websocket"
)





// Define our message object
type Message struct {
	Message  string `json:"message"`
}

var clients = make(map[*websocket.Conn]bool) // connected clients
var broadcast = make(chan Message)           // broadcast channel

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
        w.WriteHeader(http.StatusOK)
		year := r.URL.Query().Get("year")
		bbox := r.URL.Query().Get("bbox")
		style := r.URL.Query().Get("style")
		uuid := r.URL.Query().Get("uuid")
		baato_access_token := r.URL.Query().Get("baato_access_token")
		country := r.URL.Query().Get("country")

		scripts_to_run := [5]string{"/provisioning-scripts/prepare-provision.sh","/provisioning-scripts/download-data.sh","/provisioning-scripts/generate-extracts.sh","/provisioning-scripts/generate-tiles.sh","/provisioning-scripts/provision.sh"}

		for i, s := range scripts_to_run {
			cmd := exec.Command("/bin/bash", s , year, bbox, style, baato_access_token, uuid, country)
			stdout, err := cmd.Output()
			if err != nil {
			fmt.Println(err.Error())
			}
			// Print the output
			fmt.Println(i, s, string(stdout))
		}

		
        w.Write([]byte(`{"success": true}`))
    default:
        w.WriteHeader(http.StatusNotFound)
        w.Write([]byte(`{"message": "not found"}`))
    }
}

func wsHandler(w http.ResponseWriter, r *http.Request) {
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
			log.Fatal(err)
	}

	// Make sure we close the connection when the function returns
	defer ws.Close()

	// register client
	clients[ws] = true	

	for {
		var msg Message
		log.Printf(msg.Message)
		// Read in a new message as JSON and map it to a Message object
		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Printf("error: %v", err)
			delete(clients, ws)
			break
		}
		// Send the newly received message to the broadcast channel
		msge := []byte("pong")
		ws.WriteMessage(websocket.TextMessage, msge)
	}

}

// func handleMessages() {
// 	for {
// 		log.Printf(">>>@@@@@@@@@@@@")
// 		// Grab the next message from the broadcast channel
// 		val := <-broadcast
// 		msg := fmt.Sprintf("%s", val.Message)
		
// 		// Send it out to every client that is currently connected
// 		for client := range clients {
// 			err := client.WriteMessage(websocket.TextMessage, []byte(msg))
// 			if err != nil {
// 				log.Printf("error: %v", err)
// 				client.Close()
// 				delete(clients, client)
// 			}
// 		}
// 	}
// }

func main() {
    s := &server{}
    http.Handle("/api/v1/instance", s)

	// Configure websocket route
	http.HandleFunc("/ws", wsHandler)
	// Start listening for incoming chat messages
	// go handleMessages()

    log.Fatal(http.ListenAndServe(":8848", nil))
}