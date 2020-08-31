# conjur-quickstart

This repository guides you through a sample installation of Conjur Open Source
using Docker Compose.

- [Certification level](#certification-level)
- [Requirements](#requirements)
- [Usage instructions](#usage-instructions)
  * [Using this quick start with Conjur OSS](#using-this-quick-start-with-conjur-oss)
  * [Step by step guide](#step-by-step-guide)
    + [Set up a Conjur OSS environment](#set-up-a-conjur-oss-environment)
    + [Define policy](#define-policy)
    + [Store a secret](#store-a-secret)
    + [Run the demo app](#run-the-demo-app)
  * [Next steps](#next-steps)
  * [Using persistent Conjur configuration](#using-persistent-conjur-configuration)
    + [Set up a Conjur OSS environment with persistence](#set-up-a-conjur-oss-environment-with-persistence)
    + [Restarting the Conjur OSS environment using persistence](#restarting-the-conjur-oss-environment-using-persistence)
    + [Delete the Conjur data directory when done](#delete-the-conjur-data-directory-when-done)
  * [Troubleshooting](#troubleshooting)
    + [`Failed to open TCP connection` error for Conjur login](#failed-to-open-tcp-connection-error-for-conjur-login)
- [Contributing](#contributing)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Certification level

![](https://img.shields.io/badge/Certification%20Level-Community-28A745?link=https://github.com/cyberark/community/blob/master/Conjur/conventions/certification-levels.md)

This repo is a **Community** level project. It's a community contributed project
that **is not reviewed or supported by CyberArk**. For more detailed information
on our certification levels, see [our community guidelines](https://github.com/cyberark/community/blob/master/Conjur/conventions/certification-levels.md#community).

## Requirements

To follow this quick start guide, you will need to install
[Docker Toolbox](https://docs.docker.com/toolbox/overview/).

You will also need to [clone this repository](https://docs.github.com/en/enterprise/2.13/user/articles/cloning-a-repository)
to your working directory:
```
git clone https://github.com/cyberark/conjur-quickstart.git
```

## Usage instructions

### Using this quick start with Conjur OSS

We **strongly** recommend choosing the version of this project to use from the
latest [Conjur OSS suite release](https://docs.conjur.org/Latest/en/Content/Overview/Conjur-OSS-Suite-Overview.html).
Conjur maintainers perform additional testing on the suite release versions to
ensure compatibility. When possible, upgrade your Conjur version to match the
[latest suite release](https://docs.conjur.org/Latest/en/Content/ReleaseNotes/ConjurOSS-suite-RN.htm);
when using integrations, choose the latest suite release that matches your Conjur
version. For any questions, please contact us on [Discourse](https://discuss.cyberarkcommons.org/c/conjur/5).

### Step by step guide

In the sections below, we'll walk through standing this environment up step by
step. Alternatively, you can follow the instructions by visiting the web
tutorial: https://www.conjur.org/get-started/quick-start/oss-environment/.

#### Set up a Conjur OSS environment

In this unit you will learn how to install Conjur OpenSource using Docker.

At the end of this section:
You will have a working Conjur OSS environment with a Conjur account and an
admin user.

1. Pull the Docker images

   Open a terminal session and browse to `conjur-quickstart`. Pull the Docker
   images defined in `docker-compose.yml`:
   ```
   docker-compose pull
   ```

   **Verification**
   When the required images are successfully pulled, the terminal returns the
   following:
   ```
   Pulling openssl ... done
   Pulling bot_app ... done
   Pulling database ... done
   Pulling conjur ... done
   Pulling proxy ... done
   Pulling client ... done
   ```

1. Generate the master key

   The master data key will be used later to encrypt the database.
   In the working directory, generate the key and store it to a file:

   _* **Tip**: Although not mandatory, we prefer to store sensitive data to a
   file and not to display it directly on console screen._
   ```
   docker-compose run --no-deps --rm conjur data-key generate > data_key
   ```

   The data key is generated in the working directory and is stored in a file called data_key.

   **Verification**
   When the key is generated, the terminal returns the following:
   ```
   Creating network "conjur-quickstart_default" with the default driver
   ```

1. Load master key as an environment variable

   Load `data_key` file content (the master data key) as an environment variable:
   ```
   export CONJUR_DATA_KEY="$(< data_key)"
   ```

1. Start the Conjur OSS environment

   Start the Conjur OSS environment:
   ```
   docker-compose up -d
   ```

   When Conjur OSS starts, the terminal returns the following:
   ```
   Creating postgres_database ... done
   Creating bot_app ... done
   Creating openssl ... done
   Creating conjur_server ... done
   Creating nginx_proxy ... done
   Creating conjur_client ... done
   ```

   **Verification**
   Run the following command to see a list of running containers:
   ```
   docker ps -a
   ```

1. Create an admin account

   Create a Conjur account and initialize the built-in admin user.
   ```
   docker-compose exec conjur conjurctl account create myConjurAccount > admin_data
   ```

   An account named myConjurAccount is created and the admin user is initialized,
   following keys are created and stored at admin_data file:
   - admin user API key. Later on, we will use this key to log in to Conjur.
   - `myConjurAccount` Conjur account public key.

1. Connect the Conjur client to the Conjur server

   This is a one-time action. For the duration of the container’s life or until
   additional initcommand is issued, the Conjur client and the Conjur server
   remain connected.

   Use the account name that you created in step 5:
   ```
   docker-compose exec client conjur init -u conjur -a myConjurAccount
   ```

   **Verification**
   The terminal returns the following output:
   ```
   Wrote configuration to /root/.conjurrc
   ```

#### Define policy

In this unit you will learn how to load your first policy.
Formatted in YAML, policy defines Conjur entities and the relationships between
them.  An entity can be a policy, a host, a user, a layer, a group, or a variable.

A sample application policy named BotApp.yml is provided in the client container
under policy directory.

At the end of this section:
As a privileged user, you will load a policy that defines a human user, a non-human
user that represents your application, and a variable.

1. Log in to Conjur as admin

   Log in to Conjur as admin. When prompted for a password, insert the API key
   stored in the `admin_data` file:
   ```
   docker-compose exec client conjur authn login -u admin
   ```

   **Verification**
   When you successfully log in, the terminal returns:
   ```
   Logged in
   ```

1. Load the sample policy

   Load the provided sample policy into Conjur built-in `root` policy to create
   the resources for the BotApp:
   ```
   docker-compose exec client conjur policy load root policy/BotApp.yml > my_app_data
   ```

   Conjur generates the following API keys and stores them in a file, my_app_data:
   - An API key for Dave, the human user. This key is used to authenticate user
     Dave to Conjur.
   - An API key for BotApp, the non-human identity. This key is used to
     authenticate BotApp application to Conjur.

   Those API keys is correlated with the number of Users & Hosts defined in a policy.

   **Verification**
   The terminal returns:
   ```
   Loaded policy 'root'
   ```

1. Log out of Conjur

   Log out of Conjur:
   ```
   docker-compose exec client conjur authn logout
   ```

   **Verification**
   When you successfully log out, the terminal returns:
   ```
   Logged out
   ```

#### Store a secret

In this unit you will learn how to store your first secret in Conjur.

1. Log in as Dave

   Log in as Dave, the human user. When prompted for a password, copy and paste
   Dave’s API key stored in the `my_app_data` file:
   ```
   docker-compose exec client conjur authn login -u Dave@BotApp
   ```

   **Verification**
   To verify that you logged in successfully, run:
   ```
   docker-compose exec client conjur authn whoami
   ```

   The terminal returns:
   ```
   {"account":"myConjurAccount","username":"Dave@BotApp"}
   ```

1. Generate a secret

   Generate a value for your application’s secret:
   ```
   secretVal=$(openssl rand -hex 12 | tr -d '\r\n')
   ```

   This generates a 12-hex-character value.

1. Store the secret

   Store the generated value in Conjur:
   ```
   docker-compose exec client conjur variable values add BotApp/secretVar ${secretVal}
   ```

   A policy predefined variable named `BotApp/secretVar` is set with a random
   generated secret.

   **Verification**
   The terminal returns a message:
   ```
   Value added.
   ```

#### Run the demo app

In this unit you will learn how to program an application to fetch a secret from
Conjur using the REST API.

At the end of this section:
You will know how to leverage Conjur’s ability to store your application’s secrets
securely.

1. Start a bash session

   Enter the BotApp container.
   ```
   docker exec -it bot_app bash
   ```

1. Generate a Conjur token

   Generate a Conjur token to the conjur_token file, using the BotApp API key:
   ```
   curl -d "<BotApp API Key>" -k https://proxy/authn/myConjurAccount/host%2FBotApp%2FmyDemoApp/authenticate > /tmp/conjur_token
   ```

   The Conjur token is stored in the conjur_token file.

1. Fetch the secret

   Run program to fetch the secret:
   ```
   /tmp/program.sh
   ```

   The secret is displayed.

   TIP: If the secret is not displayed, try generating the token again.  You have eight minutes between generating the conjur token and fetching the secret with BotApp.

**Congratulations! You are ready to secure your own apps with Conjur.**

### Next steps

Now that you've got a local Conjur instance running, what can you do with it?

Try some of our [tutorials](https://www.conjur.org/get-started/tutorials/) on
Conjur.org.

### Using persistent Conjur configuration

With small variations to the steps outlined above, it is possible to set
up a Conjur OSS environment that retains Conjur configuration or state
across Docker container restarts. Using the steps outlined below, a
Conjur OSS environment can be set up that uses a local directory on
the host to persist Conjur configuration across container restarts.

#### Set up a Conjur OSS environment with persistence

1. If you are already running the Conjur OSS quickstart environment without
   persistence, bring down the associated containers:

   ```
   docker-compose down
   ```

1. Create a directory for storing persistent state. For example:

   ```
   mkdir temp-db-data
   ```

   _**NOTE: The permissions on this directory will automatically be changed
   to 700 by docker-compose when the directory gets host-mounted by the
   Conjur container.**_

1. Modify `docker-compose.yml` in this repository to support persistent
   storage of Conjur state. Add the following line to the bottom of the
   `database` service configuration, replacing `<PATH-TO-CONJUR-DATA-DIRECTORY>`
   with the path to the directory created in the previous step:

   ```
       volumes:
         - <PATH-TO-CONJUR-DATA-DIRECTORY>:/var/lib/postgresql/data
   ```

   For example:

   ```
       volumes:
         - /home/myusername/conjur-quickstart/temp-db-data:/var/lib/postgresql/data
   ```

1. Start the Conjur OSS environment using persistence:

   - If you had previously been running the Conjur OSS environment,
     follow the steps outlined above starting with Step 4 of the
     [Set up a Conjur OSS environment](#set-up-a-conjur-oss-environment)
     section above.
   - Otherwise, follow the steps starting with Step 1 of the
     [Set up a Conjur OSS environment](#set-up-a-conjur-oss-environment)
     section above.

#### Restarting the Conjur OSS environment using persistence

Once you have set up the Conjur OSS environment to support persistent Conjur
state, you can restart your environment as follows:

1. Bring the containers down:

   ```
   docker-compose down
   ```

   _**NOTE: You must use the `docker-compose down` command here rather than
   the `docker-compose stop` in order to avoid having stale, ephemeral
   connection state in the Conjur container. If you use the `docker-compose
   stop` command here instead, you may see errors as described in the
   [`Failed to open TCP connection` error for Conjur login](#failed-to-open-tcp-connection-error-for-conjur-login)
   section below.**_

1. Bring the containers back up:

   ```
   docker-compose up -d
   ```

1. Reconnect the Conjur client to the Conjur server. Use the account name
   that you created in the
   [Create an admin account](#create-an-admin-account) section above. For
   example:

   ```
   docker-compose exec client conjur init -u conjur -a myConjurAccount
   ```

1. Log in again to Conjur as admin. When prompted for a password, insert the
   API key stored in the `admin_data` file:

   ```
   docker-compose exec client conjur authn login -u admin
   ```

   **Verification**
   When you successfully log in, the terminal returns:
   ```
   Logged in
   ```

#### Delete the Conjur data directory when done

For added security, remember to delete the data directory that you created
in Step 1 of the
[Set up a Conjur OSS environment with persistence](#set-up-a-conjur-oss-environment-with-persistence)
section above.

## Troubleshooting

### `Failed to open TCP connection` error for Conjur login

If you are
[using persistent Conjur configuration](#using-persistent-conjur-configuration),
and you see the following error when trying to log into Conjur:

```
error: Failed to open TCP connection to conjur:80 (Connection refused - connect(2) for "conjur" port 80)
```

Then try the following:

1. Run the following command:

   ```
   docker-compose logs conjur | grep "already running"
   ```

1. If the command in Step 1 produces the following line:

   ```
   A server is already running. Check /opt/conjur-server/tmp/pids/server.pid.
   ```

   then it may be that the Conjur container was stopped (e.g.
   `docker-compose stop conjur`) and restarted
   (`docker-compose up -d conjur`)
   without being brought fully down (e.g. with `docker-compose down conjur`),
   leaving the container with stale connection state.

   To recover from this, run:

   ```
   docker-compose down conjur
   docker-compose up -d conjur
   ```

   And log in again, e.g.:

   ```
   docker-compose exec client conjur authn login -u admin
   ```

1. If "A server is already running" does not show in the Conjur container
   logs, or Step 2 above is unsuccessful, then try restarting all containers:

   ```
   docker-compose down
   docker-compose up -d
   ```

   and try logging in again, e.g.:

   ```
   docker-compose exec client conjur authn login -u admin
   ```

## Contributing

We welcome contributions of all kinds to this repository. For instructions on how
to get started and descriptions of our development workflows, please see our
[contributing guide][contrib].

[contrib]: CONTRIBUTING.md
