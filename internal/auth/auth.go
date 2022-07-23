package auth

import (
	"context"
	"crypto/sha256"
	"fmt"
	"time"

	"github.com/eveisesi/skillboard"
	"github.com/eveisesi/skillboard/internal/dynamo"
)

type Service struct {
	// env        string
	// authConfig *oauth2.Config
	// jwks       jwk.Set
	authRepo *dynamo.AuthRepostory
}

func New(authRepo *dynamo.AuthRepostory) *Service {
	return &Service{
		authRepo: authRepo,
	}
}

// func (s *Service) AuthAttempt(ctx context.Context, state string)

func (s *Service) CreateAuthAttempt(ctx context.Context) (*skillboard.AuthAttempt, error) {

	hash := fmt.Sprintf("%x", sha256.Sum256([]byte(time.Now().Format(time.RFC3339Nano))))

	attempt := &skillboard.AuthAttempt{
		State:   hash,
		Expires: time.Now().Add(time.Minute * 5).Unix(),
	}

	return attempt, s.authRepo.CreateAuthAttempt(ctx, attempt)
}
