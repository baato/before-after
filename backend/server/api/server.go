package api

import (
	"log"
	"os"
	"time"

	"github.com/getsentry/sentry-go"
	sentrygin "github.com/getsentry/sentry-go/gin"
	"github.com/gin-gonic/gin"
)

// TODO: Initialiaze using environment variables
const (
	maxWorkers   int = 1
	maxQueueSize int = 50
)

// Initiallize jobQueue
var jobQueue = make(chan Job, maxQueueSize)

// Start the dispatcher.
var dispatcher = NewDispatcher(jobQueue, maxWorkers)

type Server struct {
	router *gin.Engine
}

func NewServer() *Server {
	server := &Server{}

	server.setupRouter()

	return server
}

func (server *Server) setupRouter() {
	// Initialize Sentry
	err := sentry.Init(sentry.ClientOptions{
		Dsn:           os.Getenv("SENTRY_DSN"),
		EnableTracing: true,
		// Set TracesSampleRate to 1.0 to capture 100%
		// of transactions for performance monitoring.
		// We recommend adjusting this value in production,
		TracesSampleRate: 1.0,
	})
	if err != nil {
		log.Fatalf("sentry.Init: %s", err)
	}
	// Flush buffered events before the program terminates.
	// Set the timeout to the maximum duration the program can afford to wait.
	defer sentry.Flush(2 * time.Second)
	router := gin.Default()
	sentry.CaptureMessage("It works!")
	router.Use(sentrygin.New(sentrygin.Options{}))

	router.POST("/api/v1/instance", server.RequestHandlerForAPI)
	router.GET("/api/v1/health", server.HealthCheckHandler)

	server.router = router
}

// Start runs the http server on a specific address.
func (server *Server) Start(address string) error {

	dispatcher.Run()

	return server.router.Run(address)
}
