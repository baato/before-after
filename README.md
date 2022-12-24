# Before-after Map Generator

![Screenshot 2021-06-06 221025](https://user-images.githubusercontent.com/24402285/120932069-090c3380-c714-11eb-87e1-627a0e5273b3.png)

Technical stack for generating before-after map (with vector tiles).

# Installation and Setup

- Clone the repository
- `cp .env.sample before-after.env`
- Make required changes in .env file
- `docker-compose build`
- `docker-compose up`

# Directory Structure

- Backend: It has all the provisioning scripts and API/Websocket server written in Go.
  - The provisioning instance template is found at "backend/index.html". This is the HTML template file based on which provisioning instance is created.
- Frontend: It houses the main provisioning interface.

# Developing the Backend
- `make build` after making changes
- `make up` to test the changes

# Developing the Frontend
#### With Docker
- `make frontend` after making changes
- `make up`

#### Without Docker
- `yarn install` inside frontend/src/app
- `yarn serve`

For detailed development setup instructions have a look at our [development setup guide](development-setup.md)
