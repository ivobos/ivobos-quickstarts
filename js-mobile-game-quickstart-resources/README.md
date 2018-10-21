# appTitle
Created with https://github.com/ivobos/ivobos-quickstarts/js-mobile-game-quickstart.sh

# Prepare Dev Environment
Install nodejs and npm.
* [https://nodejs.org](https://nodejs.org)
* [https://docs.npmjs.com](https://docs.npmjs.com) 

That should be enough for a local browser dev. 

# Local browser dev loop
Develop on a local browser
```bash
npm install
npm start
```
Open browser location [http://localhost:8080/](http://localhost:8080/)

# Build for andoid
```bash
npm install
npm run android
```

# Build for iOS
```bash
npm install
npm run ios
```

# Release a version
```bash
npm version patch
```
This will bump patch version in package.json, update config.xml accordingly, create a tag and push to git. In bitbucket the new tag will trigger a build.

To release a minor version use
```bash
npm version minor
```
and for major version use
```
npm version major
```

# Steps to create Google Play Store listing
1) Navigate to https://play.google.com/apps/publish/
1) Create application
    - Default language: en-US
    - Title: appTitle
    - Short description: projectDescription
    - Full description: projectDescription
    - Screenshots
        - phone screenshots (2 minimum)
            - play-store-phone-screenshot1.png
            - play-store-phone-screenshot2.png
        - Hi-res icon
            - play-store-listing-high-res-icon.png
        - Feature graphic
            - play-store-feature-graphic.png
    - Application type: Games
    - Category: "choose your app category here"
    - Privacy policy: Not submitting plicy URL
    - SAFE DRAFT
1) Build APK in your project    
    - npm install
    - npm run android:build
    - this will create 
        - platforms/android/app/build/outputs/apk/release/app-release.apk
1) Upload APK
    - Go to App Releases
    - Select Internal test track > MANAGE
    - App signing by Google Play > OPT OUT
    - Now you have to run 
    - BROWSE FILES and select
        -  platforms/android/app/build/outputs/apk/release/app-release.apk     
    - Release name: 0.0.1
    - What's new in this release?
        - Make sure replace text with something otherwise you won't be allowed to SAVE
    - SAVE
1) Fill in content rating
    - Go to Content Rating
    - Email address: enter and confirm you email address
    - Fill in your choices, the more NO's the better
    - click CALCULATE RATING
    - click APPLY RATING
1) Pricing and distribution
    - select FREE or PAID
    - Countries: select ALL or Some
    - primary child directed: No or Yes
    - contains ads: No or Yes
    - content guidelines: tick
    - us export laws: tick
    - SAVE DRAFT
1) Roll out first release
    - go to App releases
    - go to internal test track > MANAGE
       - Users - select 
    - go to EDIT RELEASE
    - REVIEW
    - START ROLLING OUT TO INTERNAL RELEASE
    - Go to All applications
    - the app will now be "pending publication"
1) Test on android
    - install "Google Play Console" app
    - your app should now be in "Published apps" section
    - wait for it to be published
    - once published there should be a link to playstore and you can install it





