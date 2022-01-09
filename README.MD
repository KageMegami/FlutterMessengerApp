# Personna Messenger App

Our project, the Personna Messenger App, is an app based on Messenger from Facebook with a design taken from the game Personna 5.

## How to Deploy locally

"flutter run fl2_project"

## Architecture

The client app login using Firebase authentication and the token received is used to request the server.
All the clients requests are sent using http requests to our NodeJS server hosted on an OVH VPS and linked to a PostgreSQL database.
The server send message to the clients using Firebase Cloud Messaging. 

## External Libraries

**Mobile**
 - Firebase Core : https://pub.dev/packages/firebase_core               All the firebase library are use to connect to the different firebase service
 - Firebase Auth : https://pub.dev/packages/firebase_auth
 - Firebase Storage : https://pub.dev/packages/firebase_storage
 - Firebase Messaging : https://pub.dev/packages/firebase_messaging
 - Provider : https://pub.dev/packages/provider                         This is used for our global state management
 - HTTP : https://pub.dev/packages/http                                 Allow to make http request to our server
 - Image Picker : https://pub.dev/packages/image_picker                 Used to pick image from the galery
 - Image Cropper : https://pub.dev/packages/image_cropper               Used to crop picked image

**Server**
 - NestJS : https://nestjs.com/                                         This is the framework used for the server
 - TypeOrm : https://docs.nestjs.com/techniques/database                This is used to manage database entities and relations
 - Firebase Auth : https://firebase.google.com/docs/auth?authuser=0     Used to verify token send by the client to authentify request
 - Firebase Messaging : https://firebase.google.com/docs/cloud-messaging/?authuser=0#implementation_paths      Used send message and notification to client app
 - PostgreSQL : https://www.postgresql.org/                             Progresql is the database used in this project