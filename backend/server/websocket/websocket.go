package websocket

import "github.com/gorilla/websocket"

// Define our message object
type Message struct {
	Message string `json:"message"`
	Name    string `json:"name"`
	Uuid    string `json:"uuid"`
	Year    string `json:"year"`
	Bbox    string `json:"bbox"`
	Style   string `json:"style"`
	Country string `json:"country"`
}

func NotifyClient(msg string, ws *websocket.Conn) {
	// Send the newly received message to the broadcast channel
	msge := []byte(msg)
	ws.WriteMessage(websocket.TextMessage, msge)
}
