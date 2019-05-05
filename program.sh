#!/bin/bash
main() {
  CONT_SESSION_TOKEN=$(cat /tmp/conjur_token| base64 | tr -d '\r\n')
  VAR_VALUE=$(curl -s -k -H "Content-Type: application/json" -H "Authorization: Token token=\"$CONT_SESSION_TOKEN\"" https://proxy/secrets/myConjurAccount/variable/BotApp%2FsecretVar)
  echo "The retrieved value is: $VAR_VALUE"
}
main "$@"
exit
