package serializer

import (
	"time"

	db "github.com/baato/before-after/db/sqlc"
)

type UserResponse struct {
	ID              int32     `json:"id"`
	Username        string    `json:"username"`
	PictureURL      string    `json:"picture_url"`
	CreatedAt       time.Time `json:"created_at"`
	Role            int32     `json:"role"`
	EmailAddress    string    `json:"email_address"`
	IsEmailVerified bool      `json:"is_email_verified"`
}

func NewUserResponse(user db.User) UserResponse {
	return UserResponse{
		ID:              user.ID,
		Username:        user.Username,
		PictureURL:      user.PictureUrl.String,
		CreatedAt:       user.CreatedAt,
		Role:            user.Role,
		EmailAddress:    user.EmailAddress.String,
		IsEmailVerified: user.IsEmailVerified.Bool,
	}
}

type UpdateUserRequest struct {
	ID              int32  `json:"id"`
	Role            int32  `json:"role"`
	EmailAddress    string `json:"email_address"`
	IsEmailVerified bool   `json:"is_email_verified"`
}
