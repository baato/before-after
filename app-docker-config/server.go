package main

import (
    "log"
    "net/http"
	"os/exec"
	"fmt"
)

type server struct{}

func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
	//Allow CORS here By * or specific origin
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
    switch r.Method {
    case "GET":
        w.WriteHeader(http.StatusOK)
		year := r.URL.Query().Get("year")
		bbox := r.URL.Query().Get("bbox")
		style := r.URL.Query().Get("style")
		uuid := r.URL.Query().Get("uuid")
		baato_access_token := r.URL.Query().Get("baato_access_token")
		country := r.URL.Query().Get("country")
		cmd := exec.Command("/bin/bash", "/provision.sh", year, bbox, style, baato_access_token, uuid, country)
		stdout, err := cmd.Output()
		if err != nil {
			fmt.Println(err.Error())
			return
		}
		// Print the output
		fmt.Println(string(stdout))
        w.Write([]byte(`{"success": true}`))
    default:
        w.WriteHeader(http.StatusNotFound)
        w.Write([]byte(`{"message": "not found"}`))
    }
}

func main() {
    s := &server{}
    http.Handle("/", s)
    log.Fatal(http.ListenAndServe(":8848", nil))
}