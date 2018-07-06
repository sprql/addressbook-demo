# Addressbook

The project consists of 5 components:

- API
- API documentation
- API client library
- API CLI client
- API Web client

## API

Source code is located in `./api`

To run API server in docker you can use next command:

`docker run --rm --name addressbook_api -e DATABASE_URL=postgresql://username@localhost/addressbook_production -e BASIC_AUTHENTICATION_NAME=test -e BASIC_AUTHENTICATION_PASSWORD=test -e PORT=9292 -p 9292:9292 sprql/addressbook-api:latest`

where:

`DATABASE_URL` - URL to your database
`BASIC_AUTHENTICATION_NAME` - username to access to the API
`BASIC_AUTHENTICATION_PASSWORD` - password to access to the API
`PORT` - server port, the default is `9292`.


Also, you can build your docker image:

```
cd ./api && make
```



### API Documentation

Located in `./documentation`

Based on https://github.com/lord/slate


### API client library

Located in `./addressbook_client`

It's a ruby gem to expose API call in ruby.

Used in API client.


### API CLI client

Located in `./client`

To get started with client: 

```
./client help
```

By default, it assumes that a server runs on `http://localhost:9292`, and username and password for basic authentication is `development` and `development`. To change these defaults use `URL`,
`BASIC_AUTH_NANE`, `BASIC_AUTH_PASSWORD` environment variables. For example:

```
URL=https://example.com BASIC_AUTH_NANE=user BASIC_AUTH_PASSWORD=pass ./client get
```


### API Web client

Located in `./react-client`
To run the server use next command: 

```
yarn install && yarn start
```

It assumes that a server runs on `http://localhost:9292`, and username and password for basic authentication is `development` and `development`.
