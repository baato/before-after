package api

import (
	"net/http"

	"github.com/baato/before-after/services"
	"github.com/gin-gonic/gin"
	"golang.org/x/oauth2"
	"google.golang.org/appengine/log"
)

func (server *Server) login(ctx *gin.Context) {
	// TODO: Generate random state
	state := "kdbcjbjvghvdsyt637"
	url := server.config.OAUTHConfig.AuthCodeURL(state)
	ctx.JSON(
		http.StatusOK,
		gin.H{"url": url, "state": state},
	)
}

func (server *Server) callback(ctx *gin.Context) {

	// Exchange the authorization code for an access token.
	code := ctx.Query("code")
	token, err := server.config.OAUTHConfig.Exchange(oauth2.NoContext, code)
	if err != nil {
		ctx.JSON(
			http.StatusInternalServerError,
			gin.H{"error": "error while exchanging code with access token"},
		)
		return
	}

	// Fetch user details from OSM API using the access token.
	user_info, err := services.GetOSMUser(token.AccessToken)
	if err != nil {
		ctx.JSON(
			http.StatusInternalServerError,
			gin.H{"error": "error getting user details"},
		)
		log.Errorf(ctx, "error getting user details: %v", err)
		return
	}

	// Create/update user in database and return logged in user details.
	loggedInUserResponse, err := services.LoginUser(server.query, &user_info)
	if err != nil {
		ctx.JSON(
			http.StatusInternalServerError,
			gin.H{"error": "error logging in"},
		)
		log.Errorf(ctx, "error logging in: %v", err)
		return
	}
	ctx.JSON(
		http.StatusOK,
		loggedInUserResponse,
	)
}
