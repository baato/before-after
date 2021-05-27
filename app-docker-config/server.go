package main

import (
	"fmt"
	"log"
	"net/http"
	"os/exec"

	"github.com/gorilla/websocket"
)

// Define our message object
type Message struct {
	Message            string `json:"message"`
	Uuid               string `json:"uuid"`
	Year               string `json:"year"`
	Bbox               string `json:"bbox"`
	Style              string `json:"style"`
	Country            string `json:"country"`
	Baato_access_token string `json:"baato_access_token"`
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

func NotifyClient(msg string, ws *websocket.Conn) {
	// Send the newly received message to the broadcast channel
	msge := []byte(msg)
	ws.WriteMessage(websocket.TextMessage, msge)
}

func provision(year, bbox, style, uuid, baato_access_token, country string, ws *websocket.Conn) {
	scripts_to_run := [5]string{"/provisioning-scripts/prepare-provision.sh", "/provisioning-scripts/download-data.sh", "/provisioning-scripts/generate-extracts.sh", "/provisioning-scripts/generate-tiles.sh", "/provisioning-scripts/provision.sh"}

	for i, s := range scripts_to_run {
		cmd := exec.Command("/bin/bash", s, year, bbox, style, baato_access_token, uuid, country)
		stdout, err := cmd.Output()
		if err != nil {
			fmt.Println(err.Error())
		}
		// Print the output
		fmt.Println(i, s, string(stdout))
		fmt.Println(i, s)
		NotifyClient(s, ws)

	}
	NotifyClient("done", ws)
}

func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	//Allow CORS here By * or specific origin
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	switch r.Method {
	case "GET":
		w.WriteHeader(http.StatusOK)
		// year := r.URL.Query().Get("year")
		// bbox := r.URL.Query().Get("bbox")
		// style := r.URL.Query().Get("style")
		// uuid := r.URL.Query().Get("uuid")
		// baato_access_token := r.URL.Query().Get("baato_access_token")
		// country := r.URL.Query().Get("country")

		// go provision(year, bbox, style, uuid, baato_access_token, country)

		w.Write([]byte(`{"success": true, "message": "Instance is being provisioned"}`))
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
		// log.Printf(">>>>YAHHO", msg.Message)
		// Read in a new message as JSON and map it to a Message object
		err := ws.ReadJSON(&msg)
		log.Printf(msg.Year)
		if err != nil {
			log.Printf("error: %v", err)
			delete(clients, ws)
			break
		}
		if msg.Message == "provision" {
			fmt.Println(msg.Year, msg.Bbox, msg.Style, msg.Uuid, msg.Baato_access_token, msg.Country)
			go provision(msg.Year, msg.Bbox, msg.Style, msg.Uuid, msg.Baato_access_token, msg.Country, ws)
		}

	}

}

// func handleMessages() {
// 	for {

// 		// Grab the next message from the broadcast channel
// 		msg := <-broadcast
// 		log.Printf(">>>@@@@@@@@@@@@", msg.message)
// 		// if msg == "provision" {
// 		// 	go provision(val.year, val.bbox, val.style, val.uuid, val.baato_access_token, val.country)
// 		// }

// 		// // Send it out to every client that is currently connected
// 		// for client := range clients {
// 		// 	err := client.WriteMessage(websocket.TextMessage, []byte(msg))
// 		// 	if err != nil {
// 		// 		log.Printf("error: %v", err)
// 		// 		client.Close()
// 		// 		delete(clients, client)
// 		// 	}
// 		// }
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
