INSERT INTO users (
  id, username, picture_url
) VALUES (
  $1, $2, $3
)
RETURNING *;

-- name: GetUser :one
SELECT * FROM users
WHERE id = $1 LIMIT 1;


-- name: GetUserByUsername :one
SELECT * FROM users
WHERE username = $1 LIMIT 1;

-- name: ListUsers :many
SELECT * FROM users
ORDER BY username ASC
LIMIT $1 
OFFSET $2;

-- name: UpdateUser :one
UPDATE users SET 
username = COALESCE($2, username), 
role = COALESCE($3, role),
email_address = COALESCE($4, email_address),
is_email_verified = COALESCE($5, is_email_verified),
picture_url = COALESCE($6, picture_url)
WHERE id = $1
RETURNING *;

-- name: DeleteUser :exec
DELETE FROM users WHERE id = $1;
