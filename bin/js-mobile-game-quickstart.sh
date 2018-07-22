#!/bin/bash

set -e # exit on command fail
set -o pipefail # exit on command fail in a pipeline
set -u # warn about unused variables
set -E # make sure traps work with set -e

# test prerequisite commands are present
command -v cordova >/dev/null 2>&1 || { echo >&2 "cordova is required but not installed. Aborting."; exit 1; }
command -v xmlstarlet >/dev/null 2>&1 || { echo >&2 "xmlstarlet is required but not installed. Aborting."; exit 1; }
command -v cordova-icon >/dev/null 2>&1 || { echo >&2 "cordova-icon is required but not installed. Aborting."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo >&2 "npm is required but not installed. Aborting."; exit 1; }
command -v bitbucket >/dev/null 2>&1 || { echo >&2 "bitbucket is required but not installed. Aborting."; exit 1; }
command -v keytool >/dev/null 2>&1 || { echo >&2 "keytool is required but not installed. Aborting."; exit 1; }

# various paths
scriptPath="`dirname \"$0\"`"
scriptPath="`( cd \"$scriptPath\" && pwd )`"
resourcesPath="$scriptPath/../js-mobile-game-quickstart-resources"
settingsFile="$scriptPath/../.quickstarts.settings.json"

# load user settings
if [[ ! -e $settingsFile ]]; then
    echo "{}" > $settingsFile
fi
authorName=`jq -r ".author.name" $settingsFile`
if [[ $authorName = "null" ]]; then 
    authorName="" 
fi
authorEmail=`jq -r ".author.email" $settingsFile`
if [[ $authorEmail = "null" ]]; then 
    authorEmail="" 
fi
authorWebsite=`jq -r ".author.website" $settingsFile`
if [[ $authorWebsite = "null" ]]; then 
    authorWebsite="" 
fi
authorPackage=`jq -r ".author.package" $settingsFile`
if [[ $authorPackage = "null" ]]; then 
    authorPackage="" 
fi
bitbucketUsername=`jq -r ".bitbucket.username" $settingsFile`
if [[ $bitbucketUsername = "null" ]]; then 
    bitbucketUsername="" 
fi
bitbucketAppPassword=`jq -r ".bitbucket.password" $settingsFile`
if [[ $bitbucketAppPassword = "null" ]]; then 
    bitbucketAppPassword="" 
fi
googlePlayApiJsonFile=`jq -r ".google.playApiJsonFile" $settingsFile`
if [[ $googlePlayApiJsonFile = "null" ]]; then 
    googlePlayApiJsonFile="" 
fi

# parse options
OPTIND=1
projectName=""
appTitle=""
yesAll=0
while getopts "h?yp:t:" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: $0 [-h] [-?] [-y] [-p projectName] [-t appTitle]"
        exit 0
        ;;
    y)  yesAll=1
        ;;
    p)  projectName=$OPTARG
        ;;
    t)  appTitle=$OPTARG
        ;;
    esac
done


# input project name if missing
if [[ -z $projectName ]]; then
    echo -n "Enter project name (eg. space-travel-mobile): "
    read projectName
    if [[ -z "$projectName" ]]; then
        echo "Project name must be a non empty string"
        exit 1    
    fi
fi

# input app title if missing
if [[ -z $appTitle ]]; then
    echo -n "Enter application title (eg. Space Travel): "
    read appTitle
    if [[ -z "$appTitle" ]]; then
        echo "Application title be a non empty string"
        exit 1    
    fi
fi

# collect author name if necessary
if [[ -z $authorName ]]; then
    echo -n "Enter your full name: "
    read authorName
    if [[ -z $authorName ]]; then
        echo "Name must not be empty"
        exit 1
    else
        jq ".author.name = \"$authorName\"" $settingsFile > $settingsFile.new
        mv $settingsFile.new $settingsFile
    fi
fi

# collect author email if necessary
if [[ -z $authorEmail ]]; then
    echo -n "Enter your email: "
    read authorEmail
    if [[ -z $authorEmail ]]; then
        echo "Email must not be empty"
        exit 1
    else
        jq ".author.email = \"$authorEmail\"" $settingsFile > $settingsFile.new
        mv $settingsFile.new $settingsFile
    fi
fi

# collect author website if necessary
if [[ -z $authorWebsite ]]; then
    echo -n "Enter your website (must not be empty): "
    read authorWebsite
    if [[ -z $authorWebsite ]]; then
        echo "Name must not be empty"
        exit 1
    else
        jq ".author.website = \"$authorWebsite\"" $settingsFile > $settingsFile.new
        mv $settingsFile.new $settingsFile
    fi
fi

# collect author package if necessary
if [[ -z $authorPackage ]]; then
    echo -n "Enter your package (eg: com.spacegamez) (must not be empty): "
    read authorPackage
    if [[ -z $authorPackage ]]; then
        echo "Package must not be empty"
        exit 1
    else
        jq ".author.package = \"$authorPackage\"" $settingsFile > $settingsFile.new
        mv $settingsFile.new $settingsFile
    fi
fi

# collect bitbucket username if necessary
if [[ -z $bitbucketUsername ]]; then
    echo -n "Enter bitbucket user name: "
    read bitbucketUsername
    if [[ -z $bitbucketUsername ]]; then
        echo "Bitbucket username must not be empty"
        exit 1
    else
        jq ".bitbucket.username = \"$bitbucketUsername\"" $settingsFile > $settingsFile.new
        mv $settingsFile.new $settingsFile
    fi
fi

# collect bitbucket password if necessary
if [[ -z $bitbucketAppPassword ]]; then
    echo -n "Enter bitbucket app password "
    echo "(This is generated by bitbucket and can be configured in AccountSettings>AppPasswords):"
    read bitbucketAppPassword
    if [[ -z $bitbucketAppPassword ]]; then
        echo "Bitbucket password must not be empty"
        exit 1
    else
        jq ".bitbucket.password = \"$bitbucketAppPassword\"" $settingsFile > $settingsFile.new
        mv $settingsFile.new $settingsFile
    fi
fi

# collect google play api json file if necessary
if [[ -z $googlePlayApiJsonFile ]]; then
    echo -n "Enter google play api json absolute filepath: "
    read googlePlayApiJsonFile
    if [[ -z $googlePlayApiJsonFile ]]; then
        echo "google play api json file must not be empty"
        exit 1
    elif [[ ! -f $googlePlayApiJsonFile ]]; then
        echo "google play api json file not found"
        exit 1
    else
        jq ".google.playApiJsonFile = \"$googlePlayApiJsonFile\"" $settingsFile > $settingsFile.new
        mv $settingsFile.new $settingsFile
    fi
fi


# generate and default configuration properties 
projectNameLowercase=`echo $projectName | tr '[:upper:]' '[:lower:]'`
projectNameSafeId=`echo $projectNameLowercase | tr -cd '[:alnum:]'`
projectDir="$PWD/$projectNameLowercase"
projectId="$authorPackage.$projectNameSafeId"
projectDescription="$appTitle description"
bitbucketRepo="$projectNameLowercase"
bitbucketRepoUrl="https://$bitbucketUsername@bitbucket.org/$bitbucketUsername/$bitbucketRepo.git"


# print out configuration and confirm 
echo
echo "Ready to create project $projectName"
echo "Path:         $projectDir"
echo "Package id:   $projectId"
echo "Description:  $projectDescription"
echo "App title:    $appTitle"
echo "Author:       $authorName"
echo "Author email: $authorEmail"
echo "Auther site:  $authorWebsite"
echo "Bitbucket username:  $bitbucketUsername"
echo "Bitbucket app password:  $bitbucketAppPassword"
echo "Bitbucket repo: $bitbucketRepo"
echo "Bitbucket repo url: $bitbucketRepoUrl"
if [[ $yesAll -eq 0 ]]
then
    echo "Do you wish to continue? [Y/n]"
    read -rsn1 answer
    if [[ $answer != "y" && $answer != "Y" && $answer != "" ]]
    then
        echo "aborted"
        exit 1
    fi
fi

# check if bitbucket repo exists already, prompt and delete it if it does
echo "Checking if $bitbucketRepoUrl exists"
if git ls-remote -h "$bitbucketRepoUrl" &> /dev/null
then
    if [[ $yesAll -eq 0 ]]
    then
        echo "Repo exists, do you wish to delete it? [Y/n]"
        read -rsn1 answer
        if [[ $answer != "y" && $answer != "Y" && $answer != "" ]]
        then
            echo "Remove the repo manually and try again. Aborting."
            exit 1
        fi
    fi
    echo "Deleting repo $bitbucketRepoUrl"
    bitbucket delete --username $bitbucketUsername --password $bitbucketAppPassword $bitbucketRepo
fi

# now create project
set -o xtrace # print commands executed
cordova create $projectDir $projectId "$appTitle"
cd $projectDir
rm -rf $projectDir/www
mkdir $projectDir/www

# update config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:description" -v "$projectDescription" config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:author/@email" -v "$authorEmail" config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:author/@href" -v "$authorWebsite" config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:author" -v "$authorName" config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/@version" -v "0.0.1" config.xml

# merge $resourcesPath/package.json to package.json
jq -s '.[0] * .[1]' package.json $resourcesPath/package.json > package.json.new
mv package.json.new package.json

# update package.json
jq ".version = \"0.0.1\"" package.json > package.json.new
mv package.json.new package.json
jq ".description = \"$projectDescription\"" package.json > package.json.new
mv package.json.new package.json
jq ".author = \"$authorName\"" package.json > package.json.new
mv package.json.new package.json
jq "del(.main)" package.json > package.json.new
mv package.json.new package.json

# android
cordova platform add android
keytool -genkey -v -keystore android.keystore -keyalg RSA -keysize 2048 -validity 10000 -storepass "$projectName"123456 -keypass "$projectName"123456  -dname "cn=$authorName, ou=Unknown, o=Unknown, c=US"
sed "s/\$projectName/$projectName/g" package.json > package.json.new
mv package.json.new package.json

# google play
cp $googlePlayApiJsonFile google-play-api.json

# ios
cordova platform add ios

# copy resources
cp -R "$resourcesPath/src" $projectDir
cp "$resourcesPath/.gitignore" $projectDir
cp "$resourcesPath/icon.png" $projectDir
cp "$resourcesPath/icon.sketch" $projectDir
cp "$resourcesPath/webpack.config.js" $projectDir
cp "$resourcesPath/README.md" $projectDir
cp "$resourcesPath/bitbucket-pipelines.yml" $projectDir
cp "$resourcesPath/play-store-listing-high-res-icon.png" $projectDir
cp "$resourcesPath/play-store-feature-graphic.png" $projectDir
cp "$resourcesPath/play-store-phone-screenshot1.png" $projectDir
cp "$resourcesPath/play-store-phone-screenshot2.png" $projectDir

# update README.md
sed "s/appTitle/$appTitle/g" README.md > README.md.new
mv README.md.new README.md

# application icon
cordova-icon

# add packages
npm install webpack --save-dev
npm install webpack-cli --save-dev
npm install webpack-dev-server --save-dev
npm install html-webpack-plugin --save-dev
npm install clean-webpack-plugin --save-dev
npm install replace --save-dev
npm install playup --save-dev

# create bitbucket repository
bitbucket create --private --protocol ssh --scm git --username $bitbucketUsername --password $bitbucketAppPassword $bitbucketRepo
git init
git add .
git commit -m "created with https://github.com/ivobos/ivobos-quickstarts/js-mobile-game-quickstart.sh"
git remote add origin $bitbucketRepoUrl
git push -u origin master

# enable pipelines
curl -X PUT -is -u "$bitbucketUsername:$bitbucketAppPassword" -H 'Content-Type: application/json' \
https://api.bitbucket.org/2.0/repositories/$bitbucketUsername/$bitbucketRepo/pipelines_config \
 -d '{
        "enabled": true
    }'

# create first tag and trigger pipelines builds
git tag -a v0.0.1 -m "v0.0.1"
git push --tags

# npm start

# check build environment pre-requisites
# cordova requirements

# test compile everything
# cordova compile

set +o xtrace # disable command printing

# success message
echo
echo "Project $projectName created successfully"
echo "Your repo is $bitbucketRepoUrl"
echo "Your project location is $projectDir"
echo "Run local development with 'npm start'"
echo "Build iOS with 'npm run ios'"
echo "Build Android with 'npm run android'"