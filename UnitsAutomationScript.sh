#!/usr/bin/env bash
# Quick automation script to run all commands found in quickstart demo

function execute() {
  eval $1
  if [ $? -eq 0 ]; then
    echo "$1... OK"
  else
    echo "$1... FAIL"
  fi
}

# Clean previous run data.
execute 'rm -f admin_data data_key my_app_data'
execute 'docker-compose stop'


# --- UNIT 1 ----
#execute 'git clone https://github.com/cyberark/conjur-quickstart.git'

# Pull images needed for docker-compose
execute 'docker-compose pull'

# Generating data_key for conjur
execute 'docker-compose run --no-deps --rm conjur data-key generate > data_key'

# Export generated data key as environment variable
execute 'export CONJUR_DATA_KEY="$(< data_key)"'

# Starting docker-compose with selfsigned certificate
execute 'docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml up -d'

# Let services initialize fully
sleep 5

# Setting myConjurAccount to be the conjur account
execute 'docker-compose exec conjur conjurctl account create myConjurAccount > admin_data'


# --- UNIT 2 ----
# Login to Conjur as admin
execute 'docker-compose exec client conjur authn login -u admin'

# Load sample app policy
execute 'docker-compose exec client conjur policy load root policy/BotApp.yml > my_app_data'

# Log out of Conjur
execute 'docker-compose exec client conjur authn logout'


# --- UNIT 3 ----
# Login to Conjur as human user Dave
execute 'docker-compose exec client conjur authn login -u Dave@BotApp'

# Generate a secret you wish to store
execute 'secretVal=$(openssl rand -hex 12 | tr -d '\r\n')

# Store this secret inside Conjur
execute 'docker-compose exec client conjur variable values add BotApp/secretVar ${secretVal}'


# --- UNIT 4 ----
# Enter BotApp our demo application container
execute 'docker exec -it bot_app bash'

# Generate Conjur token
execute 'curl -d "<BotApp API Key>" -k https://proxy/authn/myConjurAccount/host%2FBotApp%2FmyDemoApp/authenticate > /tmp/conjur_token'

# Fetch your stored secret from Conjur using this app
execute '/tmp/program.sh'