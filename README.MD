# Personna Messenger App

Our project, the Personna Messenger App, is an app based on Messenger from Facebook with a design taken from the game Personna 5.

## How to Deploy locally

"flutter run fl2_project"

## Architecture

All the clients request are sent using http requests to our PostgreSQL Database hosted on an OVH VPS. The login functions are managed via Firebase authentication and Server - Client message are managed by Firebase Messaging. 

## External Libraries

The following libraries have been chosen because we either knew how to work with them or because we did not want to recode some of their functions.

**Mobile**
 - Firebase Core : https://pub.dev/packages/firebase_core
 - Firebase Auth : https://pub.dev/packages/firebase_auth
 - Firebase Storage : https://pub.dev/packages/firebase_storage
 - Firebase Messaging : https://pub.dev/packages/firebase_messaging
 - Provider : https://pub.dev/packages/provider
 - Cupertino Icons : https://pub.dev/packages/cupertino_icons
 - HTTP : https://pub.dev/packages/http
 - Image Picker : https://pub.dev/packages/image_picker
 - Image Cropper : https://pub.dev/packages/image_cropper

**Server**
 - NodeJS : https://nodejs.org/en/
 - NestJS : https://nestjs.com/
 - TypeOrm : https://docs.nestjs.com/techniques/database
 - Firebase Auth : https://firebase.google.com/docs/auth?authuser=0
 - Firebase Messaging : https://firebase.google.com/docs/cloud-messaging/?authuser=0#implementation_paths
 - PostgreSQL : https://www.postgresql.org/