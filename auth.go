package skillboard

import "github.com/volatiletech/null"

type AuthAttempt struct {
	State   string
	Expires int64
	Token   null.String `json:",omitempty" dynamodbav:"-"`
}
