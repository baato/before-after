package services

import (
	"bytes"
	"fmt"
	"log"
	"net/smtp"
	"os"
	"text/template"
)

func sendMail(receiver []string, body bytes.Buffer) {
	var smtpAuth = smtp.PlainAuth("", config.SMTPUsername, config.SMTPPassword, config.SMTPHost)
	var smtpURL = config.SMTPHost + ":" + config.SMTPPort

	smtp.SendMail(smtpURL, smtpAuth, config.SMTPUsername, receiver, body.Bytes())
}

func SendSuccessMail(receiver string, FullName string, Uuid string, Name string) {

	wd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	t, err := template.ParseFiles(wd + "/services/email_templates/email-template.html")
	if err != nil {
		fmt.Println(err)
	}

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
		URL:      config.HostProtocol + "//" + config.HostIP + "/provision/" + Uuid,
	})

	sendMail([]string{receiver, config.MAILCC}, body)
}

func SendErrorMail(receiver string, FullName, Uuid, ErrorAt, Year, Bbox, Name, Country, Continent, Email string) {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	t, err := template.ParseFiles(wd + "/services/email_templates/error-email-template.html")
	if err != nil {
		fmt.Println(err)
	}

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

	sendMail([]string{receiver, config.MAILCC}, body)
}
