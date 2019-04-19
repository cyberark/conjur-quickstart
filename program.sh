#!/bin/bash 
# Conjur server URL
CONJUR_APPLIANCE_URL=
https://localhost
main() {
  CONT_SESSION_TOKEN=$(cat conjur_token| base64 | tr -d '\r\n')
  VAR_VALUE=$(curl -s -k -H "Content-Type: application/json" -H "Authorization: 
Token token=\"$CONT_SESSION_TOKEN\"" 
$CONJUR_APPLIANCE_URL/secrets/myConjurAccount/variable/myApp%2FsecretVar)
  echo "Your application is authenticated and the retrieved value is: $VAR_VALUE"
}
main "$@"
exit
