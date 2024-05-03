#!/bin/bash
echo "Cleanup"
rm -f data_key admin_data my_app_data my_api_keys
echo "Stopping and Removing Container System"
podman-compose down