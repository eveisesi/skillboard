package apigw

type Middleware func(Handler) Handler

func UseMiddleware(handler Handler, wares ...Middleware) Handler {

	if len(wares) == 0 {
		return handler
	}

	for i := len(wares) - 1; i >= 0; i-- {
		handler = wares[i](handler)
	}

	return handler

}
