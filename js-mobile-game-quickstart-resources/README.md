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



