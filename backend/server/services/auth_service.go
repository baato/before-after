package services

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"time"

	db "github.com/baato/before-after/db/sqlc"
	serializer "github.com/baato/before-after/serializers"
	"github.com/baato/before-after/util"
)

type OSMResponse struct {
	User UserInfo `json:"user"`
}

type UserInfo struct {
	ID          int32   `json:"id"`
	DisplayName string  `json:"display_name"`
	Picture     Picture `json:"img"`
}
type Picture struct {
	Url string `json:"href"`
}

var config util.Config

func init() {
	config, _ = util.LoadConfig(".")
}

// Get user details from OSM API
func GetOSMUser(token string) (UserInfo, error) {
	client := &http.Client{}
	userDetailUrl := "https://openstreetmap.org/api/0.6/user/details.json"
	req, err := http.NewRequest("GET", userDetailUrl, nil)
	if err != nil {
		log.Fatalf("cannot create request:%v", err)
	}
	req.Header.Add("Authorization", "Bearer "+token)
	resp, err := client.Do(req)
	if err != nil {
		return UserInfo{}, err
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return UserInfo{}, err
	}
	var userinfo OSMResponse
	err = json.Unmarshal(body, &userinfo)
	if err != nil {
		return UserInfo{}, err
	}
	return userinfo.User, nil
}

// Create a new user in db if user not found else updates existing user and returns user
func LoginUser(query *db.Queries, userinfo *UserInfo) (serializer.UserResponse, error) {

	// Check if user exists in db
	_, getErr := query.GetUser(context.Background(), userinfo.ID)
	var user db.User
	var err error
	if getErr == nil {
		// User exists in db, so update user
		user, err = updateUser(query, userinfo)
	} else {
		// User not found in db, so create user
		user, err = createUser(query, userinfo)
	}
	if err != nil {
		return serializer.UserResponse{}, err
	} else {
		userResponse := serializer.NewUserResponse(user)
		return userResponse, nil
	}

}

// Generates session token with username and secret key
func GenerateSessionToken(userid int32) string {
	maker, err := NewJWTMaker(config.AppSecret)
	if err != nil {
		panic(err)
	}
	token, _, err := maker.CreateToken(userid, time.Hour)
	if err != nil {
		panic(err)
	}
	return token
}

// Verifies token and returns username
func VerifySessionToken(token string, userid int32) (int32, bool) {
	maker, err := NewJWTMaker(config.AppSecret)
	if err != nil {
		panic(err)
	}
	payload, err := maker.VerifyToken(token)
	if err != nil {
		panic(err)
	}
	if payload.UserID == userid {
		return payload.UserID, true
	} else {
		return 0, false
	}
}
