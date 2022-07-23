package main

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/eveisesi/skillboard/internal/apigw"
	"github.com/eveisesi/skillboard/internal/auth"
	"github.com/eveisesi/skillboard/internal/dynamo"

	awsConfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/sirupsen/logrus"
)

type app struct {
	// users       *dynamo.UserRepository
	authService *auth.Service
}

func (a *app) handleGetUserRegistration(ctx context.Context, event *events.APIGatewayV2HTTPRequest) (*events.APIGatewayV2HTTPResponse, error) {

	if event.QueryStringParameters["scopes"] == "" {
		return apigw.RespondJSONError(http.StatusBadRequest, "failed to process scopes, received empty string for required query param scopes", nil, nil)
	}

	scopes := strings.Split(event.QueryStringParameters["scopes"], ",")
	if len(scopes) == 0 {
		return apigw.RespondJSONError(http.StatusBadRequest, "failed to process scopes, expected at least one scope, got 0", nil, nil)
	}

	attempt, err := a.authService.CreateAuthAttempt(ctx)
	if err != nil {
		return apigw.RespondJSONError(http.StatusBadRequest, "failed to initialize auth attempt", nil, err)
	}

	// authorizationURI := a.auth.AuthorizationURI(ctx, attempt.State, scopes)

	return apigw.RespondJSON(http.StatusOK, attempt, nil)
}

type postUserRegistrationBody struct {
	Code  string `json:"code"`
	State string `json:"state"`
}

func (a *app) handlePostUserRegistration(ctx context.Context, event *events.APIGatewayV2HTTPRequest) (*events.APIGatewayV2HTTPResponse, error) {
	if len(event.Body) == 0 {
		return apigw.RespondJSONError(http.StatusBadRequest, "missing request body", nil, nil)
	}

	var data = new(postUserRegistrationBody)
	err := json.Unmarshal([]byte(event.Body), data)
	if err != nil {
		return apigw.RespondJSONError(http.StatusBadRequest, "failed to decode request body", nil, err)
	}

	return apigw.RespondJSON(http.StatusOK, map[string]interface{}{
		"message": "hello",
		"code":    data.Code,
		"state":   data.State,
	}, nil)

}

func main() {

	logger := logrus.New()
	logger.SetFormatter(&logrus.JSONFormatter{})

	awsConf, err := awsConfig.LoadDefaultConfig(context.TODO())
	if err != nil {
		logger.WithError(err).Fatal("failed to provision default configuration")
	}

	loadConfig(awsConf)

	dynamoClient := dynamodb.NewFromConfig(awsConf)

	authRepo := dynamo.NewAuthRepository(dynamoClient, appConfig.Dynamo.AuthTable)
	authService := auth.New(authRepo)
	// usersRepo := dynamo.NewUserRepository(dynamoClient, "skillboard-users-development")

	app := app{
		// users: usersRepo,
		authService: authService,
	}

	var routes = map[apigw.Route]apigw.Handler{
		{
			Method: http.MethodPost,
			Path:   "/users/login",
		}: app.handlePostUserRegistration,
		{
			Method: http.MethodGet,
			Path:   "/users/login",
		}: app.handleGetUserRegistration,
	}

	lambda.Start(
		apigw.UseMiddleware(
			apigw.HandleRoutes(routes),
			apigw.Cors(apigw.DefaultCorsOpt),
		),
	)

}
