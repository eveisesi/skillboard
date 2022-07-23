package main

import (
	"crypto/rsa"
	"fmt"
	"net/url"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
	"github.com/pkg/errors"

	"github.com/onetwentyseven-dev/go-config"
	ssmSource "github.com/onetwentyseven-dev/go-config/ssm"
)

// type config struct {
// 	Eve struct {
// 		ClientID           string `envconfig:"EVE_CLIENT_ID" required:"true"`
// 		ClientSecret       string `envconfig:"EVE_CLIENT_SECRET" required:"true"`
// 		CallbackURIStr     string `envconfig:"EVE_CALLBACK_URI" required:"true"`
// 		CallbackURI        *url.URL
// 		InitializeUniverse uint `envconfig:"INITIALIZE_UNIVERSE" required:"true"`
// 	}
// 	Log struct {
// 		Level string `envconfig:"LOG_LEVEL" required:"true"`
// 	}
// }

var appConfig struct {
	Eve struct {
		ClientID       string `ssm:"eve/client-id" required:"true"`
		ClientSecret   string `ssm:"eve/client-secret" required:"true"`
		CallbackURIStr string `ssm:"eve/callback-uri" required:"true"`
		CallbackURI    *url.URL
	}
	Rsa struct {
		PrivateKey64 string `ssm:"rsa/private-b64" required:"true"`
		PrivateKey   *rsa.PrivateKey
	}

	Dynamo struct {
		UserTable string `env:"USER_TABLE" required:"true"`
		AuthTable string `env:"AUTH_TABLE" required:"true"`
	}

	// S3 struct {
	// 	CharacterData string `env:"CHARACTER_DATA_BUCKET" required:"true"`
	// }
}

func loadConfig(awsConfig aws.Config) {
	env := os.Getenv("ENVIRONMENT")

	ssmClient := ssm.NewFromConfig(awsConfig)

	err := config.Process(&appConfig, ssmSource.New(fmt.Sprintf("skillboard/%s", env), ssmClient))
	if err != nil {
		panic(fmt.Sprintf("ssmconfig: %s", err))
	}

	appConfig.Eve.CallbackURI, err = url.Parse(appConfig.Eve.CallbackURIStr)
	if err != nil {
		panic(errors.Wrap(err, "failed to parse EVE_CALLBACK_URI as a valid URI"))
	}

}
