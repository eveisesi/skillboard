package dynamo

import (
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
)

type UserRepository struct {
	tableName string
	client    *dynamodb.Client
}

func NewUserRepository(client *dynamodb.Client, tableName string) *UserRepository {
	return &UserRepository{
		tableName: tableName,
		client:    client,
	}
}

// func (r *UserRepository) CreateUser(ctx context.Context)
