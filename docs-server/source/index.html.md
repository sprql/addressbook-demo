---
title: API Reference

language_tabs:
  - shell

includes:
  - errors

search: true
---

# Introduction

Addressbook API implemented according to [JSON API Specification v1.0](http://jsonapi.org)

<aside class="notice">
Clients MUST send all JSON API data in request documents with the header `Content-Type: application/vnd.api+json` without any media type parameters.
</aside>

# Authentication

API uses [basic authentication schema](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)

API expects for the basic authentication to be included in all API requests to the server in a header that looks like the following:

`Authorization: Basic ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ=`

<aside class="notice">
You must replace <code>ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ=</code> with your <code>username:password</code> encoded in Base64.
</aside>

# Objects

## Contact Object

> Example:

```json
{
  "id": "644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b",
  "type": "contact",
  "attributes": {
    "first_name": "Brendan",
    "last_name": "Quigley",
    "phone": "903-709-6192 x16401",
    "address": "United States of America, Jacobishire, 47099 Myah Fort"
  }
}
```

Attributes:              | &nbsp;
-------------------------|------------
`id`                     | **string**
`type`                   | **string**, _value is "contact"_
`attributes[first_name]` | **string**, contact's first name
`attributes[last_name]`  | **string**, contact's last name
`attributes[phone]`      | **string**, contact's phone
`attributes[address]`    | **string**, contact's address


# Contacts

## Get All Contacts

> Request:

```shell
curl 'https://example.com/contacts' -H 'Authorization: Basic ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ=' -H 'Content-Type: application/vnd.api+json'
```

> Response:

```json
HTTP/1.1 200 OK
Content-Type: application/vnd.api+json

{
  "data": [
    {
      "id": "644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b",
      "type": "contact",
      "attributes": {
        "first_name": "Brendan",
        "last_name": "Quigley",
        "phone": "903-709-6192 x16401",
        "address": "United States of America, Jacobishire, 47099 Myah Fort"
      }
    },
    {
      "id": "2405c7ca-9352-4611-911c-a92b27274061",
      "type": "contact",
      "attributes": {
        "first_name": "Chandler",
        "last_name": "Ziemann",
        "phone": "436-920-2223 x31050",
        "address": "Argentina, Jacobsonport, 47274 Baumbach Extension"
      }
    }
  ]
}
```

This endpoint retrieves all contacts.

### HTTP Request

`GET https://example.com/contacts`

### URL Parameters

Parameter | Description
--------- | -----------
`query`   | **string**, filter contacts according to `query`

<aside class="success">
Remember — all API endpoints requires basic authentication
</aside>


## Get a Contact

> Request:

```shell
curl 'https://example.com/contacts/644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b' -H 'Authorization: Basic ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ=' -H 'Content-Type: application/vnd.api+json'
```

> Response:

```json
HTTP/1.1 200 OK
Content-Type: application/vnd.api+json

{
  "data": {
    "id": "644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b",
    "type": "contact",
    "attributes": {
      "first_name": "Brendan",
      "last_name": "Quigley",
      "phone": "903-709-6192 x16401",
      "address": "United States of America, Jacobishire, 47099 Myah Fort"
    }
  }
}
```

This endpoint retrieves a specific contact.

### HTTP Request

`GET https://example.com/contacts/<ID>`

### URL Parameters

Parameter | Description
--------- | -----------
`ID`      | The ID of the contact to retrieve


## Create a Contact

> Request:

```shell
curl -X POST 'https://example.com/contacts/' -H 'Authorization: Basic ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ=' -H 'Content-Type: application/vnd.api+json' -d '{"data": { "type": "contact", "attributes": {"first_name": "Brendan", "last_name": "Quigley", "phone": "903-709-6192 x16401", "address": "United States of America, Jacobishire, 47099 Myah Fort"}}}'
```

> Response:

```json
HTTP/1.1 201 Created
Content-Type: application/vnd.api+json

{
  "data": {
    "type": "contact",
    "attributes": {
      "first_name": "Brendan",
      "last_name": "Quigley",
      "phone": "903-709-6192 x16401",
      "address": "United States of America, Jacobishire, 47099 Myah Fort"
    }
}
```

This endpoint creates a contact.

### HTTP Request

`POST https://example.com/contacts/`

### Data Parameters

Parameter | Type |Description
--------- |------|-----------
`data[type]` | **string** | Type of object, should be `contact`
`data[attributes][first_name]` | **string** | Contact's first name
`data[attributes][last_name]` | **string** | Contact's last name
`data[attributes][phone]` | **string** | Contact's phone
`data[attributes][address]` | **string** | Contact's address


## Update a Contact

> Request:

```shell
curl -v -X PATCH 'https://example.com/contacts/644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b' -H 'Authorization: Basic ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ=' -H 'Content-Type: application/vnd.api+json' -H 'If-None-Match: W/"8f84aef2dec662e4dfc6a6496423463d"' -H 'If-Modified-Since: Thu, 05 Jul 2018 08:00:22 GMT' -d '{"data": { "id": "644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b", "type": "contact", "attributes": {"phone": "6192 x16401"}}}'
```

> Response:

```json
HTTP/1.1 204 No Content
```

This endpoint updates a specific contact.

### HTTP Request

`PATCH https://example.com/contacts/<ID>`

### URL Parameters

Parameter | Description
--------- | -----------
ID        | The ID of the contact to update

### Data Parameters

Parameter | Type |Description
--------- |------|-----------
`data[id]` | **string** | ID of object
`data[type]` | **string** | Type of object, should be `contact`
`data[attributes][first_name]` | **string** | Contact's first name
`data[attributes][last_name]` | **string** | Contact's last name
`data[attributes][phone]` | **string** | Contact's phone
`data[attributes][address]` | **string** | Contact's address

<aside class="notice">
You must provide <code>If-None-Match</code> and <code>If-Modified-Since</code> headers with values obtained from <code>ETag</code> and <code>Last-Modified</code> headers accordingly.

To obtain <code>ETag</code> and <code>Last-Modified</code> headers you can request resource as described in <a href="#get-a-contact">Get a Contact</a>
</aside>


## Upload an Image for a Contact

> Request:

```shell
curl 'https://example.com/contacts/644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b/upload' -H 'Authorization: Basic ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ=' -F 'data=@path/to/local/file'
```

> Response

```json
HTTP/1.1 204 No Content
```

This endpoint upload an image for a specific contact.


### HTTP Request

`POST https://example.com/contacts/<ID>/upload`

### URL Parameters

Parameter | Description
--------- | -----------
`ID`      | The ID of the contact


### Data Parameters

Parameter | Description
--------- | -----------
`data`    | Content of a uploaded file


<aside class="notice">
You must use <code>'Content-Type: multipart/form-data'</code> header</aside>


## Get an image for a Contact

> Request:

```shell
curl 'https://example.com/contacts/644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b/image' -H 'Authorization: Basic ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ='
```

> Response

```json
HTTP/1.1 200 Ok
Content-Type: image/jpeg
Content-Disposition: inline; filename="644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b"
Content-Transfer-Encoding: binary

<binary data>
```

This endpoint get an image for a specific contact.

### HTTP Request

`GET https://example.com/contacts/<ID>/image`

### URL Parameters

Parameter | Description
--------- | -----------
`ID`      | The ID of the contact


## Delete a Contact

> Request:

```shell
curl 'https://example.com/contacts/644f2b54-4b1d-4cf8-b1da-e8d22ae4f96b' -X DELETE -H 'Authorization: Basic ZGV2ZWxvcG1lbnQ6ZGV2ZWxvcG1lbnQ='
```

> Response

```json
HTTP/1.1 204 No Content
```


This endpoint deletes a specific contact.

### HTTP Request

`DELETE https://example.com/contacts/<ID>`

### URL Parameters

Parameter | Description
--------- | -----------
`ID`      | The ID of the contact to delete


