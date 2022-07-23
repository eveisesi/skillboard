package apigw

import (
	"context"
	"fmt"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
)

type Handler func(context.Context, *events.APIGatewayV2HTTPRequest) (*events.APIGatewayV2HTTPResponse, error)

type Route struct {
	Method, Path string
}

func (r *Route) routeKey() string {
	return fmt.Sprintf("%s %s", r.Method, r.Path)
}

func HandleRoutes(routes map[Route]Handler) Handler {
	mapped := make(map[string]Handler)
	for route, handler := range routes {
		mapped[route.routeKey()] = handler
	}

	return func(ctx context.Context, input *events.APIGatewayV2HTTPRequest) (*events.APIGatewayV2HTTPResponse, error) {
		if handler, ok := mapped[input.RouteKey]; ok {
			return handler(ctx, input)
		}

		resp := map[string]string{"error": "route not found"}

		return RespondJSON(http.StatusNotFound, resp, nil)
	}

}
