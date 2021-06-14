package workerpool

import (
	"fmt"
	"os/exec"

	Websocket "../websocket"
	"github.com/gorilla/websocket"
)

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

func provision(year, bbox, style, name, uuid, country string, ws *websocket.Conn) {
	scripts_to_run := [5]string{"/provisioning-scripts/prepare-provision.sh", "/provisioning-scripts/download-data.sh", "/provisioning-scripts/generate-extracts.sh", "/provisioning-scripts/generate-tiles.sh", "/provisioning-scripts/provision.sh"}

	for i, s := range scripts_to_run {
		Websocket.NotifyClient(s, ws)
		cmd := exec.Command("/bin/bash", s, year, bbox, style, uuid, country, name)
		cmd.Output()
		// Print the output
		fmt.Println(i, s)
	}
	Websocket.NotifyClient("done", ws)
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

				// fmt.Printf("MAATHI\n", job.Uuid, job.Name)
				// time.Sleep(5 * time.Second)
				// fmt.Printf("TALA\n", job.Uuid, job.Name)
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

func (d *Dispatcher) Run() {
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

func RequestHandler(msg Websocket.Message, ws *websocket.Conn, jobQueue chan Job) {
	// go provision(msg.Year, msg.Bbox, msg.Style, msg.Name, msg.Uuid, msg.Country, ws)
	// Create Job and push the work onto the jobQueue.
	job := Job{Year: msg.Year, Bbox: msg.Bbox, Style: msg.Style, Name: msg.Name, Uuid: msg.Uuid, Country: msg.Country, ws: ws}

	jobQueue <- job
}
