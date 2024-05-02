import subprocess
import os
import sys
import time
import random
import string

def announce(message):
    print("++++++++++++++++++++++++++++++++++++++")
    print("")
    print(message)
    print("")
    print("++++++++++++++++++++++++++++++++++++++")

def cleanup(exit_status, exit_command):
    if exit_status != 0:
        print("\nWORKFLOW FAILED.\n")
        print("Cleanup")
        for file_name in ["data_key", "admin_data", "my_app_data", "my_api_keys"]:
            if os.path.exists(file_name):
                os.remove(file_name)
        print("Stopping and Removing Container System")
        subprocess.run(["podman-compose", "down"])
    sys.exit(exit_status)

def execute_command(command):
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        cleanup(e.returncode, command)

def login_as_admin(command):
    max_retries = 3
    retry_interval = 10
    retries = 0

    while retries < max_retries:
        retries += 1

        print(f"Attempt {retries}: Logging in as admin...")
        try:
            execute_command(command)
            print("Login successful")
            return
        except subprocess.CalledProcessError:
            print("Login attempt failed")
            time.sleep(retry_interval)

    print("Maximum retries reached. Failed to log in as admin.")
    cleanup(1, "podman exec --interactive conjur_client conjur login -i admin -p ${admin_api_key}")

if __name__ == "__main__":
    subprocess.run(["set", "-euo", "pipefail"], check=True)
    subprocess.run(["trap", "cleanup EXIT ABRT QUIT"], check=True)

    ps_output = subprocess.check_output(["podman-compose", "ps", "-q"])
    if ps_output:
        print("Conjur Quickstart OSS already built!")
        print("Testing Quickstart workflow requires a fresh build.")
        print("Use 'podman-compose down' to remove current Quickstart build.")
        sys.exit(0)

    announce("UNIT 1. Set Up a Conjur OSS Environment")

    execute_command("podman-compose pull")
    print("")

    execute_command("podman run --rm cyberark/conjur data-key generate > data_key")
    print("")

    conjur_data_key = open("data_key").read().strip()
    os.environ["CONJUR_DATA_KEY"] = conjur_data_key
    print("Step 3: Load data key as environment variable")
    print("")

    execute_command("podman-compose up -d")
    print("")

    execute_command("podman-compose exec -T conjur conjurctl wait -r 120 -p 80")
    print("")

    execute_command("podman-compose exec -T conjur conjurctl account create myConjurAccount > admin_data")
    print("")

    print("Step 6: Connect the Conjur client to the Conjur server")
    # `echo "Y"` is used to accept the self-signed certificate
    execute_command("echo 'Y' | podman container exec -i conjur_client conjur init -u https://proxy -a myConjurAccount --self-signed")
    print("")

    announce("UNIT 2. Define Policy")

    admin_api_key = subprocess.check_output(["awk", "/API key for admin/{print $NF}", "admin_data"]).decode().strip()
    command = f"podman exec --interactive conjur_client conjur login -i admin -p {admin_api_key}"
    subprocess.run(["trap", "", "EXIT ABRT QUIT"], check=True)
    login_as_admin(command)

    subprocess.run(["trap", "cleanup EXIT ABRT QUIT"], check=True)

    execute_command("podman-compose exec -T client conjur policy load -b root -f policy/BotApp.yml > my_app_data")
    print("")

    execute_command("podman-compose exec -T client conjur logout")
    print("")

    announce("UNIT 3. Store a Secret in Conjur")

    dave_api_key = subprocess.check_output(["awk", "'/\"api_key\":/{print $NF}'", "my_app_data"]).decode().strip()
    execute_command(f"podman-compose exec -T client conjur login -i Dave@BotApp -p {dave_api_key}")
    print("")

    secret_val = ''.join(random.choices(string.ascii_letters + string.digits, k=12))
    print("Step 2: Generate Secret")
    print("")

    execute_command(f"podman-compose exec -T client conjur variable set -i BotApp/secretVar -v {secret_val}")
    print("")

    announce("UNIT 4. Run the Demo App")

    bot_api_key = subprocess.check_output(["awk", "'NR==1'"]).decode().strip()
    execute_command(f"podman-compose exec -T bot_app bash -c \"curl -d '{bot_api_key}' -k https://proxy/authn/myConjurAccount/host%2FBotApp%2FmyDemoApp/authenticate > /tmp/conjur_token\"")
    print("")

    fetched = subprocess.check_output(["podman-compose", "exec", "-T", "bot_app", "bash", "-c", "/tmp/program.sh"]).decode().strip()
    print("Step 3: Fetch Secret")
    print("")

    print("Step 4: Compare Generated and Fetched Secrets")
    print(f"Generated:\t{secret_val}")
    print(f"Fetched:\t{fetched.split(':')[-1].strip()}")
    if secret_val == fetched.split(':')[-1].strip():
        print("Generated secret matches secret fetched by Bot App")
        print("WORKFLOW PASSED.")
    else:
        print("Generated secret does not match the secret fetched by Bot App")
        sys.exit(1)
