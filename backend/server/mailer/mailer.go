package mailer

import (
	"bytes"
	"fmt"
	"log"
	"net/smtp"
	"os"
	"text/template"
	"time"
)

var GMAIL_USERNAME = os.Getenv("GMAIL_USERNAME")
var GMAIL_PASSWORD = os.Getenv("GMAIL_PASSWORD")
var gmailAuth = smtp.PlainAuth("", GMAIL_USERNAME, GMAIL_PASSWORD, "smtp.gmail.com")

// deliver sends the message but never blocks the caller for longer than the
// timeout, and skips entirely when SMTP credentials are not configured. This
// prevents a missing/blocked mail server from stalling the provisioning worker.
func deliver(receiver []string, body []byte) {
	if GMAIL_USERNAME == "" || GMAIL_PASSWORD == "" {
		log.Println("[mailer] GMAIL_USERNAME/GMAIL_PASSWORD not set; skipping e-mail")
		return
	}
	done := make(chan error, 1)
	go func() {
		done <- smtp.SendMail("smtp.gmail.com:587", gmailAuth, GMAIL_USERNAME, receiver, body)
	}()
	select {
	case err := <-done:
		if err != nil {
			log.Printf("[mailer] send failed: %v\n", err)
		}
	case <-time.After(20 * time.Second):
		log.Println("[mailer] send timed out after 20s; continuing")
	}
}

func SendMail(receiver []string, FullName string, Uuid string, Name string) {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	t, err := template.ParseFiles(wd + "/mailer/email-template.html")
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

	deliver(receiver, body.Bytes())
}

func SendErrorMail(receiver []string, FullName, Uuid, ErrorAt, Year, Bbox, Name, Country, Continent, Email string) {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	t, err := template.ParseFiles(wd + "/mailer/error-email-template.html")
	fmt.Println(err)

	var body bytes.Buffer
	headers := "MIME-version: 1.0;\nContent-Type: text/html;"
	body.Write([]byte(fmt.Sprintf("Subject: Before after maps generated\n%s\n\n", headers)))

	t.Execute(&body, struct {
		FullName  string
		Name      string
		Uuid      string
		ErrorAt   string
		Year      string
		Bbox      string
		Country   string
		Continent string
		Email     string
	}{
		FullName:  FullName,
		Name:      Name,
		Uuid:      Uuid,
		ErrorAt:   ErrorAt,
		Year:      Year,
		Bbox:      Bbox,
		Country:   Country,
		Continent: Continent,
		Email:     Email,
	})

	deliver(receiver, body.Bytes())
}
