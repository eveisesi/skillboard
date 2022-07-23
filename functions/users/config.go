package main

import (
	"context"
	"fmt"
	"net/url"

	"github.com/aws/aws-sdk-go-v2/aws"
	ssmconfig "github.com/onetwentyseven-dev/go-ssm-config"
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

var ssmConfig struct {
	EveClientID       string `ssm:"eve/client-id" required:"true"`
	EveClientSecret   string `ssm:"eve/client-secret" required:"true"`
	EveCallbackURIStr string `ssm:"eve/callback-uri" required:"true"`
	EveCallbackURI    *url.URL
}

func loadConfig(awsConfig aws.Config) {

	err := ssmconfig.Process(context.TODO(), awsConfig, "skillboard", &ssmConfig)
	if err != nil {
		panic(fmt.Sprintf("ssmconfig: %s", err))
	}

}
