package apigw

import (
	"context"
	"net/http"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/go-http-utils/headers"
)

type CorsOpts struct {
	Origins, Methods, Headers []string
}

var DefaultCorsOpt = &CorsOpts{
	Methods: []string{"GET", "POST", "PATCH", "DELETE", "OPTIONS"},
	Headers: []string{"Accept", "Content-Type", "User-Agent"},
	Origins: []string{"*"},
}

func Cors(opts *CorsOpts) Middleware {
	return func(next Handler) Handler {
		return func(ctx context.Context, req *events.APIGatewayV2HTTPRequest) (*events.APIGatewayV2HTTPResponse, error) {
			hders := buildCorsHeaders(opts, req)

			if req.RequestContext.HTTP.Method == http.MethodOptions {
				return &events.APIGatewayV2HTTPResponse{
					StatusCode: http.StatusNoContent,
					Headers:    hders,
				}, nil
			}

			results, err := next(ctx, req)
			if err != nil {
				return results, err
			}

			if results.Headers == nil {
				results.Headers = make(map[string]string)
			}

			for h, v := range hders {
				results.Headers[h] = v
			}

			return results, nil
		}
	}
}

func buildCorsHeaders(opts *CorsOpts, req *events.APIGatewayV2HTTPRequest) map[string]string {
	hdrs := make(map[string]string)

	if len(opts.Headers) > 0 {
		hdrs[headers.AccessControlAllowHeaders] = strings.Join(opts.Headers, ",")
	}

	if len(opts.Methods) > 0 {
		hdrs[headers.AccessControlAllowMethods] = strings.Join(opts.Methods, ",")
	}
	if len(opts.Origins) > 0 {
		hdrs[headers.AccessControlAllowOrigin] = strings.Join(opts.Origins, ",")
	}

	// if len(opts.Origins) > 0 && req.Headers["origin"] != "" {
	// 	originHeader := req.Headers["origin"]

	// 	for _, origin := range opts.Origins {
	// 		if matchOrigin(origin, originHeader) {
	// 			hdrs[headers.AccessControlAllowOrigin] = originHeader
	// 			break
	// 		}
	// 	}
	// }

	return hdrs
}
