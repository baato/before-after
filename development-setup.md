# Development setup
## Understanding the code
### Architecture
Before After is composed of three parts:

- **Frontend**: A user interface built using Vue js.
- **Database**: A postgres database with postgis extension.
- **Backend**: Backend is made of four major components.
    - ***server***: Consists of golang code responsible for creating API server in order to communicate with frontend.
    - ***map-styles***: Consists of 3 baato mapstyles i.e. *`retro`*, *`breeze`* and *`monochrome`* for styling of before after maps.
    - ***provisioning-scripts***: Consists shell scripts that are used to download required data from geofabric, generate tiles and provision before-after maps.
    - ***tilemaker-configs***: Consists of configuration files for tilemaker.

### Frontend
This is the front-end user interface of the Before-After. It is based on the Vue js and you can find all files in the `frontend` directory.

The following dependencies must be available _globally_ on your system:
* Download and install [NodeJS LTS v12+](https://nodejs.org/en/) and [yarn](https://classic.yarnpkg.com/en/docs/install)
* Go into the `frontend` directory and execute `yarn`.

#### Available Scripts

From project root cd into `frontend/src/app`, then you can run:

##### `yarn start`

Runs the app in the development mode.<br>
Open [http://localhost:8080](http://localhost:8080) to view it in the browser.

The page will reload if you make edits.<br>
You will also see any lint errors in the console.


##### `yarn build`

Builds the app for production to the `build` folder.<br>
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.<br>
Your app is ready to be deployed!

#### Using Make
Make sure [Docker CE](https://www.docker.com/community-edition#/download) is  available locally:

Then you can, 
- Build frontend image using `make frontend`.
- If you plan to setup frontend only comment out all other services on `docker-compose.yml` then run command `make up`.
- Stop running docker containers using `make down`.

### Backend

The backend is made up of a postgres database, API server that calls various end points for user authentication and to create provisons, provisioning scripts to provision before-after maps, mapstyles for styling of maps and tilemaker configs for configuring tilemakers.

#### Dependencies

* [Golang 1.18+](https://go.dev/dl/)
* [PostgreSQL](https://www.postgresql.org/download/) with [PostGIS](https://postgis.net/install/)
* [tilemaker](https://github.com/systemed/tilemaker.git)
* [sqlc](https://docs.sqlc.dev/en/stable/overview/install.html)

You can check the backend [Dockerfile](Dockerfile.backend) to have a reference of other system dependencies and how to install them in a Debian/Ubuntu system.

#### Configuration

There are two ways to configure Before After. You can set some environment variables on your shell or you can define the configuration in the `before-after.env` file on the repository root directory. To use that last option, follow the below instructions:

* Copy the example configuration file to start your own configuration: `cp .env.sample before-after.env`.
* Adjust the `before-after.env` configuration file to fit your configuration.
* Make sure that the following variables are set correctly in the `before-after.env` configuration file:
  - `POSTGRES_DB`=tasking-manager-database-name
  - `POSTGRES_USER`=database-user-name
  - `POSTGRES_PASSWORD`=database-user-password
  - `POSTGRES_HOST`=database-endpoint-can-be-localhost
  - `POSTGRES_PORT`=database-port
  - `DB_DRIVER`=postgres (recommended)
  - `OAUTH_CLIENT_ID`=oauth2-client-id-from-openstreetmapA
  - `OAUTH_CLIENT_SECRET`=oauth2-client-secret-key-from-openstreetmap
  - `OAUTH_SCOPES`=scope-for-oauth2-application
  - `OAUTH_REDIRECT_URL`=defined-during-oauth2-application-cretion
  - `OAUTH_SERVER_URL`=https://www.openstreetmap.org
  - `TM_SECRET`=define-freely-any-number-and-letter-combination
  - `TM_CONSUMER_KEY`=oauth-consumer-key-from-openstreetmap
  - `TM_CONSUMER_SECRET`=oauth-consumer-secret-key-from-openstreetmap

In order to send email correctly, set these variables as well:
  - `SMTP_HOST`
  - `SMTP_PORT`
  - `SMTP_USERNAME`
  - `SMTP_PASSWORD`
  - `MAIL_CC`=Email will be sent to this address as well after provisioning is complete

### Database

#### Create a fresh database

We use [golang migrate](https://github.com/golang-migrate/migrate) to create the database from the migrations directory. Check the instructions on how to setup a PostGIS database with [docker](#creating-a-local-postgis-database-with-docker) or on your [local system](#non-docker). 
Install golang migrate:
```bash
    curl -s https://packagecloud.io/install/repositories/golang-migrate/migrate/script.deb.sh | sudo bash
    sudo apt-get update
    sudo apt-get install -y migrate
```
Then you can execute the following command to apply the migrations:

Modify DBSource in format `postgresql://<POSTGRES_USER>:<PASSWORD>@<POSTGRES_HOST>:<POSTGRES_PORT>/<POSTGRES_DB>?sslmode=disable` and export it as your env variable.
```bash
    export DBSource=postgresql://baato:baato@postgres:5432/before-after?sslmode=disable
    migrate -path backend/server/db/migration -database ${DBSource} -verbose up
```
