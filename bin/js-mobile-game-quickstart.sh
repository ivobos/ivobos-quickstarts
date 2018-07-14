#!/bin/bash

set -e # exit on command fail
set -o pipefail # exit on command fail in a pipeline
set -u # warn about unused variables
set -E # make sure traps work with set -e

# test prerequisite commands are present
command -v cordova >/dev/null 2>&1 || { echo >&2 "cordova is required but not installed. Aborting."; exit 1; }
command -v xmlstarlet >/dev/null 2>&1 || { echo >&2 "xmlstarlet is required but not installed. Aborting."; exit 1; }
command -v cordova-icon >/dev/null 2>&1 || { echo >&2 "cordova-icon is required but not installed. Aborting."; exit 1; }
command -v yarn >/dev/null 2>&1 || { echo >&2 "yarn is required but not installed. Aborting."; exit 1; }

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

# generate and default configuration properties 
projectNameLowercase=`echo $projectName | tr '[:upper:]' '[:lower:]'`
projectNameSafeId=`echo $projectNameLowercase | tr -cd '[:alnum:]'`
projectDir="$PWD/$projectNameLowercase"
projectId="$authorPackage.$projectNameSafeId"
projectDescription="$appTitle description"

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

# merge $resourcesPath/package.json to package.json
jq -s '.[0] * .[1]' package.json $resourcesPath/package.json > package.json.new
mv package.json.new package.json

# update package.json
jq ".description = \"$projectDescription\"" package.json > package.json.new
mv package.json.new package.json
jq ".author = \"$authorName\"" package.json > package.json.new
mv package.json.new package.json
jq "del(.main)" package.json > package.json.new
mv package.json.new package.json

cordova platform add android
cordova platform add ios

# copy resources
cp -R "$resourcesPath/src" $projectDir
cp "$resourcesPath/.gitignore" $projectDir
cp "$resourcesPath/icon.png" $projectDir
cp "$resourcesPath/icon.sketch" $projectDir
cp "$resourcesPath/webpack.config.js" $projectDir

# update webpack.config.js
# sed "s/appTitle/$appTitle/g" webpack.config.js > webpack.config.js.new
# mv webpack.config.js.new webpack.config.js

# appllication icon
cordova-icon

# add packages
yarn add webpack webpack-cli webpack-dev-server html-webpack-plugin clean-webpack-plugin --dev

# yarn start

# check build environment pre-requisites
# cordova requirements

# test compile everything
# cordova compile

set +o xtrace # disable command printing

# success message
echo
echo "Project $projectName created successfully"
echo "Your project location is $projectDir"
echo "Run local development with 'yarn start'"
echo "Build iOS with 'yarn run ios'"
echo "Build Android with 'yarn run android'"