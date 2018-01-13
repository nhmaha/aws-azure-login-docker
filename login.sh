#!/bin/bash -x

[[ -z $TENNANT_ID ]] && (echo "Environment variable TENNANT_ID must be set" && exit 1)

if [[ ! -z $EMAIL_ADDRESS ]]; then
  USERNAME_PARAM="--username $EMAIL_ADDRESS"
fi

if [[ -z $PROFILE ]]; then
  PROFILE=dev-ad
fi

/node_modules/.bin/aws-azure-login --configure --no-prompt --app-id-uri urn:amazon:webservices --tenant-id $TENNANT_ID --username $EMAIL_ADDRESS --profile $PROFILE
/node_modules/.bin/aws-azure-login --profile $PROFILE --chrome google-chrome-unstable
