#!/usr/bin/env bash

# Clean previous run data.
rm -f admin_data data_key

docker-compose stop
if [ $? -eq 0 ]; then
    echo "docker-compose stop... OK"
else
    echo "docker-compose stop... FAIL"
fi

# Pull images needed for docker-compose
docker-compose pull
if [ $? -eq 0 ]; then
    echo "docker-compose pull... OK" 
else
    echo "docker-compose pull... FAIL"
fi

# Generating data_key for conjur
docker-compose run --no-deps --rm conjur data-key generate > data_key
if [ $? -eq 0 ]; then
    echo "docker-compose run --no-deps --rm conjur data-key generate > data_key... OK"
else
    echo "docker-compose run --no-deps --rm conjur data-key generate > data_key... FAIL"
fi

# Export generated data key as environment variable
export CONJUR_DATA_KEY="$(< data_key)"
if [ $? -eq 0 ]; then
    echo "export CONJUR_DATA_KEY... OK"
else
    echo "export CONJUR_DATA_KEY... FAIL"
fi

# Starting docker-compose with selfsigned certificate
docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml up -d
if [ $? -eq 0 ]; then
    echo "docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml up -d... OK"
else
    echo "docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml up -d... FAIL"
fi

# Let services initialize fully
sleep 5

# Setting myConjurAccount to be the conjur account
docker-compose exec conjur conjurctl account create myConjurAccount > admin_data
if [ $? -eq 0 ]; then
    echo "docker-compose exec conjur conjurctl account create myConjurAccount > admin_data... OK"
else
    echo "docker-compose exec conjur conjurctl account create myConjurAccount > admin_data... FAIL"
fi
