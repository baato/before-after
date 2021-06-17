package mailer

import (
	"bytes"
	"fmt"
	"log"
	"net/smtp"
	"os"
	"text/template"
)

var GMAIL_USERNAME = os.Getenv("GMAIL_USERNAME")
var GMAIL_PASSWORD = os.Getenv("GMAIL_PASSWORD")
var gmailAuth = smtp.PlainAuth("", GMAIL_USERNAME, GMAIL_PASSWORD, "smtp.gmail.com")

func SendMail(receiver []string, FullName string, Uuid string, Name string) {

	wd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	t, err := template.ParseFiles(wd + "/backend/server/mailer/email-template.html")
	fmt.Println(err)

	var body bytes.Buffer
	headers := "MIME-version: 1.0;\nContent-Type: text/html;"
	body.Write([]byte(fmt.Sprintf("Subject: Before after maps generated\n%s\n\n", headers)))

	t.Execute(&body, struct {
		FullName string
		Name     string
		URL      string
	}{
		FullName: FullName,
		Name:     Name,
		URL:      os.Getenv("HOST_PROTOCOL") + "//" + os.Getenv("HOST_IP") + "/provision/" + Uuid,
	})

	smtp.SendMail("smtp.gmail.com:587", gmailAuth, GMAIL_USERNAME, receiver, body.Bytes())

}
