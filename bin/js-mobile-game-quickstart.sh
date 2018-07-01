#!/bin/bash

set -e # exit on command fail
set -o pipefail # exit on command fail in a pipeline
set -u # warn about unused variables
set -E # make sure traps work with set -e

# various paths
scriptPath="`dirname \"$0\"`"
scriptPath="`( cd \"$scriptPath\" && pwd )`"
resourcesPath="$scriptPath/../js-mobile-game-quickstart-resources"

# test prerequisite commands are present
set -o xtrace # enable command printing
which cordova
which xmlstarlet
which cordova-icon
which yarn

# parse options
OPTIND=1
projectName=""
yesAll=0
while getopts "h?yp:" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: $0 [-h] [-?] [-y] [-p projectName]"
        exit 0
        ;;
    y)  yesAll=1
        ;;
    p)  projectName=$OPTARG
        ;;
    esac
done


# collect input configuration
set +o xtrace # disable command printing
if [[ -z $projectName ]]
then
    echo -n "Enter project name: "
    read userInput
    if [[ -n "$userInput" ]]
    then
        projectName=$userInput
    else
        echo "Project name must be a non empty string"
        exit 1    
    fi
fi

# generate and default configuration properties 
projectNameLowercase=`echo $projectName | tr '[:upper:]' '[:lower:]'`
projectDir="$PWD/ivobos-$projectNameLowercase"
projectId=net.aptive.$projectNameLowercase
projectDescription="$projectName description"
appTitle=$projectName
authorName="Ivo Bosticky"
authorEmail="ivobos@gmail.com"
authorWebsite="http://aptive.net"

# print out configuration and confirm 
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
    echo $answer
    if [[ $answer != "y" && $answer != "Y" && $answer != "" ]]
    then
        echo "aborted"
        exit 1
    fi
fi

# now create project
set -o xtrace # print commands executed
cordova create $projectDir $projectId $appTitle
cd $projectDir
# rm -rf $projectDir/www

# update config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:description" -v "$projectDescription" config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:author/@email" -v "$authorEmail" config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:author/@href" -v "$authorWebsite" config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:author" -v "$authorName" config.xml

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
cp -R "$resourcesPath/" $projectDir

# appllication icon
cordova-icon

# add packages
yarn add webpack webpack-cli --dev

# check build environment pre-requisites
cordova requirements

# test compile everything
cordova compile

# success message
set +o xtrace # disable command printing
echo
echo "Project $projectName created successfully"
echo "Your project location is $projectDir"
echo "Run local development with 'yarn start'"
echo "Build iOS with 'yarn run ios'"
echo "Build Android with 'yarn run android'"