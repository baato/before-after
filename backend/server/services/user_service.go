package services

import (
	"context"
	"database/sql"

	db "github.com/baato/before-after/db/sqlc"
)

// Create a new user in db
func createUser(query *db.Queries, userinfo *UserInfo) (db.User, error) {
	arg := db.CreateUserParams{
		ID:         userinfo.ID,
		Username:   userinfo.DisplayName,
		PictureUrl: sql.NullString{String: userinfo.Picture.Url, Valid: true},
	}
	user, err := query.CreateUser(context.Background(), arg)
	return user, err
}

// Updates existing user in db
func updateUser(query *db.Queries, userinfo *UserInfo) (db.User, error) {
	arg := db.UpdateUserParams{
		ID:         userinfo.ID,
		Username:   userinfo.DisplayName,
		PictureUrl: sql.NullString{String: userinfo.Picture.Url, Valid: true},
	}
	user, err := query.UpdateUser(context.Background(), arg)
	return user, err
}
