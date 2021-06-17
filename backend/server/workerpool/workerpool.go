package workerpool

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"

	Mailer "../mailer"
	Websocket "../websocket"
	"github.com/gorilla/websocket"
)

// Job holds the attributes needed to perform unit of work.

type Job struct {
	Year      string
	Bbox      string
	Style     string
	Name      string
	Uuid      string
	Country   string
	Continent string
	FullName  string
	Email     string
	// ws        *websocket.Conn
}

type JobStatus struct{ status, err string }

func provision(year, bbox, style, name, uuid, country, continent, fullName, email string) JobStatus {
	scripts_to_run := [5]string{"/provisioning-scripts/prepare-provision.sh", "/provisioning-scripts/download-data.sh", "/provisioning-scripts/generate-extracts.sh", "/provisioning-scripts/generate-tiles.sh", "/provisioning-scripts/provision.sh"}

	for i, s := range scripts_to_run {
		// Websocket.NotifyClient(s, ws)
		cmd := exec.Command("/bin/bash", s, year, bbox, style, uuid, country, name, continent)
		_, err := cmd.Output()
		if err != nil {
			fmt.Println(fmt.Sprint(err))
			return JobStatus{"error", s}
		}
		// Print the output
		fmt.Println(i, s)
	}
	return JobStatus{"done", "nil"}
	// Websocket.NotifyClient("done", ws)
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
				var jobstatus JobStatus = provision(job.Year, job.Bbox, job.Style, job.Name, job.Uuid, job.Country, job.Continent, job.FullName, job.Email)
				if jobstatus.status == "done" {
					Mailer.SendMail([]string{job.Email, os.Getenv("MAIL_CC")}, job.FullName, job.Uuid, job.Name)
				} else if jobstatus.status == "error" {
					Mailer.SendErrorMail([]string{job.Email, os.Getenv("MAIL_CC")}, job.FullName, job.Uuid, jobstatus.err, job.Year, job.Bbox, job.Name, job.Country, job.Continent, job.Email)
				}

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

func RequestHandlerForSocket(msg Websocket.Message, ws *websocket.Conn, jobQueue chan Job) {
	// Create Job and push the work onto the jobQueue.
	job := Job{Year: msg.Year, Bbox: msg.Bbox, Style: msg.Style, Name: msg.Name, Uuid: msg.Uuid, Country: msg.Country, Continent: msg.Continent}
	jobQueue <- job
}

func RequestHandlerForAPI(r *http.Request, jobQueue chan Job) {
	// Create Job and push the work onto the jobQueue.
	job := Job{
		Year:      r.URL.Query().Get("year"),
		Bbox:      r.URL.Query().Get("bbox"),
		Style:     r.URL.Query().Get("style"),
		Name:      r.URL.Query().Get("name"),
		Uuid:      r.URL.Query().Get("uuid"),
		Country:   r.URL.Query().Get("country"),
		Continent: r.URL.Query().Get("continent"),
		FullName:  r.URL.Query().Get("fullName"),
		Email:     r.URL.Query().Get("email"),
	}
	jobQueue <- job
}
