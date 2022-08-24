package api

import (
	db "github.com/baato/before-after/db/sqlc"
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
	query  *db.Queries
	config *util.Config
}

func NewServer(query *db.Queries, config *util.Config) *Server {
	server := &Server{
		config: config,
		query:  query,
	}

	server.setupRouter()

	return server
}

func (server *Server) setupRouter() {
	router := gin.Default()

	router.GET("/api/v1/login", server.login)
	router.GET("/api/v1/callback", server.callback)
	router.POST("/api/v1/instance", server.RequestHandlerForAPI)

	server.router = router
}

// Start runs the http server on a specific address.
func (server *Server) Start(address string) error {

	dispatcher.Run()

	return server.router.Run(address)
}
