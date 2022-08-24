package services

import (
	"errors"
	"fmt"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/google/uuid"
)

const minSecretKeySize = 12

var (
	ErrInvalidToken = errors.New("token is invalid")
	ErrExpiredToken = errors.New("token is expired")
)

type JwtMaker struct {
	secretKey string
}

type Payload struct {
	ID        uuid.UUID `json:"id"`
	UserID    int32     `json:"user_id"`
	IssuedAt  time.Time `json:"issued_at"`
	ExpiresAt time.Time `json:"expires_at"`
}

func NewPayload(userid int32, duration time.Duration) (*Payload, error) {
	tokenID, err := uuid.NewRandom()
	if err != nil {
		return nil, err
	}

	payload := &Payload{
		ID:        tokenID,
		UserID:    userid,
		IssuedAt:  time.Now(),
		ExpiresAt: time.Now().Add(duration),
	}

	return payload, nil
}

func (payload *Payload) Valid() error {
	if time.Now().After(payload.ExpiresAt) {
		return ErrExpiredToken
	}
	return nil
}

func NewJWTMaker(secretKey string) (*JwtMaker, error) {
	if len(secretKey) < minSecretKeySize {
		return nil, fmt.Errorf("secret key is too short")
	}
	return &JwtMaker{secretKey}, nil
}

// CreateToken generates a JWT token with the given payload.
func (maker *JwtMaker) CreateToken(userid int32, duration time.Duration) (string, *Payload, error) {
	payload, err := NewPayload(userid, duration)
	if err != nil {
		return "", &Payload{}, err
	}
	jwtToken := jwt.NewWithClaims(jwt.SigningMethodHS256, payload)
	token, err := jwtToken.SignedString([]byte(maker.secretKey))
	return token, payload, err
}

// VerifyToken verifies given token string and returns Payload
func (maker *JwtMaker) VerifyToken(token string) (*Payload, error) {

	// func to test signing method used to create string
	keyFunc := func(token *jwt.Token) (interface{}, error) {
		_, ok := token.Method.(*jwt.SigningMethodHMAC)
		if !ok {
			return nil, ErrInvalidToken
		}
		return []byte(maker.secretKey), nil
	}

	// Parse token and return err if invalid or expired
	jwtToken, err := jwt.ParseWithClaims(token, &Payload{}, keyFunc)

	// Check if the error returned is for invalid token or expired token
	if err != nil {
		verr, ok := err.(*jwt.ValidationError)
		if ok && errors.Is(verr.Inner, ErrExpiredToken) {
			return nil, ErrExpiredToken
		}
		return nil, ErrInvalidToken
	}

	payload, ok := jwtToken.Claims.(*Payload)
	if !ok {
		return nil, ErrInvalidToken
	}

	return payload, nil
}
