package services

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
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
