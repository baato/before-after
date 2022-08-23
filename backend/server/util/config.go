package util

import (
	"github.com/spf13/viper"
)

// Config stores all configuration of the application.
// The values are read by viper from a config file or environment variable.
type Config struct {
	HostProtocol string `mapstructure:"HOST_PROTOCOL"`
	HostIP       string `mapstructure:"HOST_IP"`
	SMTPHost     string `mapstructure:"SMTP_HOST"`
	SMTPPort     string `mapstructure:"SMTP_PORT"`
	SMTPUsername string `mapstructure:"SMTP_USERNAME"`
	SMTPPassword string `mapstructure:"SMTP_PASSWORD"`
	MAILCC       string `mapstructure:"MAIL_CC"`
	APIBaseURL   string `mapstructure:"API_BASE_URL"`
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
	return
}
