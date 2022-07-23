package dynamo

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/eveisesi/skillboard"
	"github.com/pkg/errors"
)

type AuthRepostory struct {
	tableName *string
	client    *dynamodb.Client
}

func NewAuthRepository(client *dynamodb.Client, tableName string) *AuthRepostory {
	return &AuthRepostory{
		tableName: aws.String(tableName),
		client:    client,
	}
}

func (r *AuthRepostory) AuthAttempt(ctx context.Context, state string) (*skillboard.AuthAttempt, error) {

	result, err := r.client.GetItem(ctx, &dynamodb.GetItemInput{
		TableName: r.tableName,
		Key: map[string]types.AttributeValue{
			"State": &types.AttributeValueMemberS{
				Value: state,
			},
		},
	})
	if err != nil {
		return nil, err
	}

	var attempt = new(skillboard.AuthAttempt)
	return attempt, attributevalue.UnmarshalMap(result.Item, attempt)

}

func (r *AuthRepostory) CreateAuthAttempt(ctx context.Context, input *skillboard.AuthAttempt) error {

	item, err := attributevalue.MarshalMap(input)
	if err != nil {
		return errors.Wrap(err, "failed to marshal item for dynamo")
	}

	_, err = r.client.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: r.tableName,
		Item:      item,
	})

	return err

}
