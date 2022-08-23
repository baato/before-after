package api

import (
	"github.com/baato/before-after/util"
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
	config *util.Config
}

func NewServer(config *util.Config) *Server {
	server := &Server{
		config: config,
	}

	server.setupRouter()

	return server
}

func (server *Server) setupRouter() {
	router := gin.Default()
	router.POST("/api/v1/instance", server.RequestHandlerForAPI)

	server.router = router
}

// Start runs the http server on a specific address.
func (server *Server) Start(address string) error {

	dispatcher.Run()

	return server.router.Run(address)
}
