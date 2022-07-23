package apigw

import (
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
	"github.com/sirupsen/logrus"
)

// Respond is a simple response with a status and body
func respond(status int, body string, headers map[string]string, isBase64Encoded bool) (*events.APIGatewayV2HTTPResponse, error) {

	if headers == nil {
		headers = map[string]string{}
	}

	e := &events.APIGatewayV2HTTPResponse{
		StatusCode: status,
		Headers:    headers,
	}

	if body != "" {
		e.Body = body
		e.IsBase64Encoded = isBase64Encoded
	}

	return e, nil
}

// RespondError returns a response while logging an error
func RespondError(status int, body string, headers map[string]string, err error) (*events.APIGatewayV2HTTPResponse, error) {
	return respond(status, body, headers, false)
}

// RespondJSON returns a json-formatted response
func RespondJSON(status int, body interface{}, headers map[string]string) (*events.APIGatewayV2HTTPResponse, error) {
	if headers == nil {
		headers = map[string]string{}
	}

	if body == nil {
		return respond(status, "", headers, false)
	}

	headers["Content-Type"] = "application/json"

	data, err := json.Marshal(body)
	if err != nil {
		return RespondError(status, `{"error": "an internal error occurred"}`, headers, err)
	}

	return respond(status, string(data), headers, false)
}

// RespondJSONError returns a json-formatted error response
func RespondJSONError(status int, msg string, headers map[string]string, err error) (*events.APIGatewayV2HTTPResponse, error) {
	if err != nil {
		logger.WithError(err).WithFields(logrus.Fields{
			"status": status,
		}).Error(msg)
	}

	s := map[string]string{"error": msg}

	return RespondJSON(status, s, headers)

}
