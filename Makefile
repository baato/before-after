backend:
	docker build -t before-after_backend:latest . -f Dockerfile.backend

frontend:
	docker build -t before-after_frontend:latest ./frontend

up:
    docker-compose up -d

down:
	docker-compose down

sqlc:
	sqlc generate

initmigrate:
	 migrate create -ext sql -dir backend/server/db/migration -seq init_schema

dbupgrade:
	migrate -path db/migration -database "postgresql://baato:baato@localhost:5432/beforeafter?sslmode=disable" -verbose up

dbdowngrade:
	migrate -path db/migration -database "postgresql://baato:baato@localhost:5432/beforeafter?sslmode=disable" -verbose down

server:
	cd backend/server/
	go run main.go


.PHONY: backend frontend up down initmigrate dbupgrade dbdowngrade sqlc server