package api

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"time"

	Mailer "github.com/baato/before-after/mailer"
	"github.com/gin-gonic/gin"
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
		fmt.Printf("\n=== [%s] step %d/%d: %s ===\n", uuid, i+1, len(scripts_to_run), s)
		cmd := exec.Command("/bin/bash", s, year, bbox, style, uuid, country, name, continent)
		// Stream the script's output live so long-running steps (wget, osmium,
		// tilemaker) are visible and errors surface immediately instead of the
		// whole job appearing to hang.
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Env = os.Environ()

		start := time.Now()
		if err := cmd.Run(); err != nil {
			fmt.Printf("=== [%s] FAILED at %s after %s: %v ===\n", uuid, s, time.Since(start).Round(time.Second), err)
			return JobStatus{"error", s}
		}
		fmt.Printf("=== [%s] OK %s (%s) ===\n", uuid, s, time.Since(start).Round(time.Second))
	}
	return JobStatus{"done", "nil"}
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
				// Send notification e-mails asynchronously: a slow or
				// misconfigured SMTP server must never block the worker (and
				// therefore every subsequent job) from making progress.
				if jobstatus.status == "done" {
					go Mailer.SendMail([]string{job.Email, os.Getenv("MAIL_CC")}, job.FullName, job.Uuid, job.Name)
				} else if jobstatus.status == "error" {
					go Mailer.SendErrorMail([]string{job.Email, os.Getenv("MAIL_CC")}, job.FullName, job.Uuid, jobstatus.err, job.Year, job.Bbox, job.Name, job.Country, job.Continent, job.Email)
				}

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

func (server *Server) RequestHandlerForAPI(ctx *gin.Context) {
	// Create Job and push the work onto the jobQueue.
	job := Job{}
	if err := ctx.ShouldBindJSON(&job); err != nil {
		ctx.JSON(http.StatusBadRequest, err)
		return
	}
	jobQueue <- job
	ctx.JSON(http.StatusOK, "Instance is being provisioned")
}

// A dumb API to return server health
func (server *Server) HealthCheckAPI(ctx *gin.Context) {
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Server is fit and healthy!",
	})
}
