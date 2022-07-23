package apigw

import (
	"context"
	"net/http"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/go-http-utils/headers"
)

func ContentType(ct string) Middleware {
	return func(next Handler) Handler {
		return func(ctx context.Context, event *events.APIGatewayV2HTTPRequest) (*events.APIGatewayV2HTTPResponse, error) {
			contentType, ok := event.Headers[strings.ToLower(headers.ContentType)]
			if ok && contentType != ct {
				return &events.APIGatewayV2HTTPResponse{
					StatusCode: http.StatusUnsupportedMediaType,
				}, nil
			}

			return next(ctx, event)

		}
	}
}
