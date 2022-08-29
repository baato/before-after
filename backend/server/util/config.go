package util

import (
	"fmt"

	"github.com/spf13/viper"
	"golang.org/x/oauth2"
)

// Config stores all configuration of the application.
// The values are read by viper from a config file or environment variable.
type Config struct {
	DBDriver          string        `mapstructure:"DB_DRIVER"`
	DBSource          string        `mapstructure:"-"`
	PostgresUser      string        `mapstructure:"POSTGRES_USER"`
	PostgresPassword  string        `mapstructure:"POSTGRES_PASSWORD"`
	PostgresDB        string        `mapstructure:"POSTGRES_DB"`
	PostgresHost      string        `mapstructure:"POSTGRES_HOST"`
	PostgresPort      string        `mapstructure:"POSTGRES_PORT"`
	PostgresSSL       string        `mapstructure:"POSTGRES_SSL_MODE"`
	HostProtocol      string        `mapstructure:"HOST_PROTOCOL"`
	HostIP            string        `mapstructure:"HOST_IP"`
	SMTPHost          string        `mapstructure:"SMTP_HOST"`
	SMTPPort          string        `mapstructure:"SMTP_PORT"`
	SMTPUsername      string        `mapstructure:"SMTP_USERNAME"`
	SMTPPassword      string        `mapstructure:"SMTP_PASSWORD"`
	MAILCC            string        `mapstructure:"MAIL_CC"`
	AppSecret         string        `mapstructure:"APP_SECRET"`
	OAUTHClientID     string        `mapstructure:"OAUTH_CLIENT_ID"`
	OAUTHClientSecret string        `mapstructure:"OAUTH_CLIENT_SECRET"`
	OAUTHScopes       []string      `mapstructure:"OAUTH_SCOPES"`
	OAUTHRedirectURL  string        `mapstructure:"OAUTH_REDIRECT_URL"`
	OAUTHServerURL    string        `mapstructure:"OAUTH_SERVER_URL"`
	OAUTHConfig       oauth2.Config `mapstructure:"-"`
}

// LoadConfig reads configuration from file or environment variables.
func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName("before-after")
	viper.SetConfigType("env")

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)

	// Create DBSource using env variables
	// e.g. DBSource postgresql://<user>:<password>@<host>:<port>/<db>?sslmode=<disable>
	config.DBSource = fmt.Sprint(
		"postgresql://",
		config.PostgresUser, ":", config.PostgresPassword, "@",
		config.PostgresHost, ":", config.PostgresPort, "/", config.PostgresDB,
		"?sslmode=", config.PostgresSSL,
	)

	// Create OAuth config using env vatiables
	config.OAUTHConfig.RedirectURL = config.OAUTHRedirectURL
	config.OAUTHConfig.ClientID = config.OAUTHClientID
	config.OAUTHConfig.ClientSecret = config.OAUTHClientSecret
	config.OAUTHConfig.Scopes = config.OAUTHScopes
	config.OAUTHConfig.Endpoint = oauth2.Endpoint{
		AuthURL:  config.OAUTHServerURL + "/oauth2/authorize",
		TokenURL: config.OAUTHServerURL + "/oauth2/token",
	}

	return
}
