#!/bin/bash 
migrate -path ./backend/server/db/migration -database ${DBSource} -verbose up