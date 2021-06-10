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
	Message string `json:"message"`
	Name    string `json:"name"`
	Uuid    string `json:"uuid"`
	Year    string `json:"year"`
	Bbox    string `json:"bbox"`
	Style   string `json:"style"`
	Country string `json:"country"`
}

var clients = make(map[*websocket.Conn]bool) // connected clients

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

func provision(year, bbox, style, name, uuid, country string, ws *websocket.Conn) {
	scripts_to_run := [5]string{"/provisioning-scripts/prepare-provision.sh", "/provisioning-scripts/download-data.sh", "/provisioning-scripts/generate-extracts.sh", "/provisioning-scripts/generate-tiles.sh", "/provisioning-scripts/provision.sh"}

	for i, s := range scripts_to_run {
		NotifyClient(s, ws)
		cmd := exec.Command("/bin/bash", s, year, bbox, style, uuid, country, name)
		stdout, err := cmd.Output()
		if err != nil {
			fmt.Println(err.Error())
		}
		// Print the output
		fmt.Println(i, s, string(stdout))
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
		w.Write([]byte(`{"success": true, "message": "Instance is being provisioned"}`))
	default:
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte(`{"message": "not found"}`))
	}
}

// func wsHandler(w http.ResponseWriter, r *http.Request) {
// 	ws, err := upgrader.Upgrade(w, r, nil)
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	// Make sure we close the connection when the function returns
// 	defer ws.Close()

// 	// register client
// 	clients[ws] = true

// 	for {
// 		var msg Message
// 		// Read in a new message as JSON and map it to a Message object
// 		err := ws.ReadJSON(&msg)
// 		if err != nil {
// 			log.Printf("error: %v", err)
// 			delete(clients, ws)
// 			break
// 		}
// 		if msg.Message == "provision" {
// 			go provision(msg.Year, msg.Bbox, msg.Style, msg.Name, msg.Uuid, msg.Country, ws)
// 		}
// 	}
// }

// Job holds the attributes needed to perform unit of work.

type Job struct {
	Year    string
	Bbox    string
	Style   string
	Name    string
	Uuid    string
	Country string
	ws      *websocket.Conn
}

// NewWorker creates takes a numeric id and a channel w/ worker pool.
func NewWorker(id int, workerPool chan chan Job) Worker {
	return Worker{
		id:         id,
		jobQueue:   make(chan Job),
		workerPool: workerPool,
		quitChan:   make(chan bool),
	}
}

type Worker struct {
	id         int
	jobQueue   chan Job
	workerPool chan chan Job
	quitChan   chan bool
}

func (w Worker) start() {
	go func() {
		for {
			// Add my jobQueue to the worker pool.
			w.workerPool <- w.jobQueue

			select {
			case job := <-w.jobQueue:
				// Dispatcher has added a job to my jobQueue.

				provision(job.Year, job.Bbox, job.Style, job.Name, job.Uuid, job.Country, job.ws)

				// fmt.Printf("worker%d: started %s, blocking for %f seconds\n", w.id, job.Name, job.Delay.Seconds())
				// time.Sleep(job.Delay)
				// fmt.Printf("worker%d: completed %s!\n", w.id, job.Name)
			case <-w.quitChan:
				// We have been asked to stop.
				fmt.Printf("worker%d stopping\n", w.id)
				return
			}
		}
	}()
}

func (w Worker) stop() {
	go func() {
		w.quitChan <- true
	}()
}

// NewDispatcher creates, and returns a new Dispatcher object.
func NewDispatcher(jobQueue chan Job, maxWorkers int) *Dispatcher {
	workerPool := make(chan chan Job, maxWorkers)

	return &Dispatcher{
		jobQueue:   jobQueue,
		maxWorkers: maxWorkers,
		workerPool: workerPool,
	}
}

type Dispatcher struct {
	workerPool chan chan Job
	maxWorkers int
	jobQueue   chan Job
}

func (d *Dispatcher) run() {
	for i := 0; i < d.maxWorkers; i++ {
		worker := NewWorker(i+1, d.workerPool)
		worker.start()
	}

	go d.dispatch()
}

func (d *Dispatcher) dispatch() {
	for {
		select {
		case job := <-d.jobQueue:
			go func() {
				fmt.Printf("fetching workerJobQueue for: %s\n", job.Name)
				workerJobQueue := <-d.workerPool
				fmt.Printf("adding %s to workerJobQueue\n", job.Name)
				workerJobQueue <- job
			}()
		}
	}
}

func requestHandler(msg Message, ws *websocket.Conn, jobQueue chan Job) {
	// go provision(msg.Year, msg.Bbox, msg.Style, msg.Name, msg.Uuid, msg.Country, ws)
	// Create Job and push the work onto the jobQueue.
	job := Job{Year: msg.Year, Bbox: msg.Bbox, Style: msg.Style, Name: msg.Name, Uuid: msg.Uuid, Country: msg.Country, ws: ws}

	jobQueue <- job
}

func main() {
	s := &server{}
	var maxWorkers int = 2
	var maxQueueSize int = 10

	// Create the job queue.
	jobQueue := make(chan Job, maxQueueSize)

	// Start the dispatcher.
	dispatcher := NewDispatcher(jobQueue, maxWorkers)
	dispatcher.run()

	http.Handle("/api/v1/instance", s)
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
			var msg Message
			// Read in a new message as JSON and map it to a Message object
			err := ws.ReadJSON(&msg)
			if err != nil {
				log.Printf("error: %v", err)
				delete(clients, ws)
				break
			}
			if msg.Message == "provision" {
				requestHandler(msg, ws, jobQueue)

			}
		}
	})
	// Start listening for incoming chat messages
	// go handleMessages()
	log.Fatal(http.ListenAndServe(":8848", nil))
}
