#!/bin/bash
# Conjur server URL
CONJUR_APPLIANCE_URL=http://10.0.68.207:8080
main() {
  CONT_SESSION_TOKEN=$(cat conjur_token| base64 | tr -d '\r\n')
  VAR_VALUE=$(curl -s -k -H "Content-Type: application/json" -H "Authorization: Token token=\"$CONT_SESSION_TOKEN\"" $CONJUR_APPLIANCE_URL/secrets/myConjurAccount/variable/myApp%2FsecretVar)
  echo "The retrieved value is: $VAR_VALUE"
}
main "$@"
exit
