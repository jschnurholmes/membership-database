# cdny-members
#### A Rails app for administering a database of members and memberships
#### Technologies used: mariadb, ruby, rails

## Table of Contents:
### [Creating a development environment](#dev-env-setup)
1. [Set up Prerequisites](#prerequisites)
    1. [Create `ssh` credentials](#ssh-credentials)
    2. [Set up Bitbucket.org account](#bitbucket-setup)
    3. [Install `docker`](#install-docker)
    4. [Configure `git`](#configure-git)    

2. [Prepare development environment](#prepare-environment)
    1. [Fetch source code](#fetch-code)
    2. [Create `.env` file](#create-env)
    3. [Start components](#start-components)
    4. [Initialize database](#initialize-database)
    5. [Confirm installation success](#confirm-success)  

### [Administrative Tasks](#administrative-tasks)
* [Create a new user](#create-user)
* [Create a new membership year](#create-membeship-period)
* [Change user password](#change-user-password)
* [Change user email](#change-user-email)

## <a name='dev-env-setup'></a>Creating a development Environment
#### This project uses docker compose for local development

## <a name='prerequisites'></a>Set up prerequisites
First, set up a few tools needed to fetch and run the project. Open a terminal to run the following  commands.

### <a name='ssh-credentials'></a>Create `ssh` credentials
SSH credentials are used to authenticate with the remote `git` server. To create a public/private keypair, enter the command
```shell
ssh-keygen -b 4096
```
You will see a series of prompts, and can press enter at each to accept the default value. This will create a folder (`.ssh`) in your home directory containing 2 files:

1. `id_rsa` - This is your new _private_ key, and should be kept secure.
2. `id_rsa.pub` - This is your new _public_ key, which you will share with Bitbucket so they can authenticate you. This file can be re-created from your private key if it is lost

### <a name='bitbucket-setup'></a>Set up Bitbucket.org account
Go to [Bitbucket.org](https://bitbucket.org) and create an account if you do not have one already. If you do have an account, log in.

Once you are logged in:

1. Click on the gear near the top-right corner of the Bitbucket site, and click `Personal Bitbucket settings` from the menu that appears.
2. On the left side of the person settings pagej, under `Security`, click `SSH keys`
3. On the SSH keys page, click the blue `Add key` button.
4. In the Add SSH key dialog that pops up, enter a name for Label and paste the contents of `id_rsa.pub` from the previous step into the `Key` field. Click the blue `Add key` button at the bottom right of the dialog.

### <a name='install-docker'></a>Install docker
Docker is used to run the project's code in a container, which is an isolated environment that is consistent across different host operating systems. In order to install `docker`, [add the official Docker repository to your package manager's source list](https://docs.docker.com/engine/install/) after uninstalling any versions that may already be present on your system.  
[For Ubuntu](https://docs.docker.com/engine/install/ubuntu/):
```shell
# Uninstall old versions of docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done


# Set up Docker's official repository:
#   Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

#   Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update


# Install docker
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Give your user permission to run `docker` commands
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```


### <a name='configure-git'></a>Configure `git`
`git` is the source code management tool used for managing the project code. In order to fetch and work on the project, `git` needs some minimal configuration:
```shell
# If you don't have git installed already, first install it
sudo apt install git

# Once git is installed, configure settings to identify yourself when changing the code:
git config --global user.name 'Jane Smith'
git config --global user.email 'jane.smith@example.com'
```

At this point you should have all necessary prerequisites installed, and can proceed to fetch and set up the project  

## <a name='prepare-environment'></a>Prepare development environment

### <a name='fetch-code'></a>Fetch the code
First, decided where you want to keep you source code. This example will use `~/src` as the code root (i.e., all projects will be subfolders of `~/src`)
```shell
# If the folder you want to use for your code root doesn't exist, create it  
mkdir -p ~/src

# Move to the code root
cd ~/src

# Fetch the code
git clone git@bitbucket.org:cdny/cdny-members.git

# Move to the project folder
cd cdny-members

# Check out the development environment branch
git checkout feature/docker-dev-environment
```

### <a name='create-env'></a>Create `.env` file
Set up some local configuration values:  
In the root of the `cdny-members` project, create a fie called `.env`, with the following contents:
```dotenv
# Development Database Settings
MYSQL_ROOT_PASSWORD=<some random password>
MYSQL_DATABASE=members_dev
MYSQL_USER=members
MYSQL_PASSWORD=members
MARIADB_VERSION=10.11
```
Save the file.

### <a name='start-components'></a>Start components
Start up docker containers with the database server and the rails app
```shell
docker-compose up -d
```

### <a name='initialize-database'></a>Initialize database
Connect to the running app container and run the database initialization script
First, get the container ID of the rails app:
```shell
docker ps
```
you will see output similar to
```shell
CONTAINER ID   IMAGE              COMMAND                  CREATED          STATUS         PORTS                    NAMES
2c9b3a9044b6   cdny-members-app   "bash -c 'rm -f tmp/…"   10 seconds ago   Up 9 seconds   0.0.0.0:8080->8080/tcp   cdny-members-app-1
f55a92509ea9   mariadb:10.11      "docker-entrypoint.s…"   10 seconds ago   Up 9 seconds   3306/tcp                 cdny-members-mariadb-1
```
Copy the container id of the `cdny-members-app` container (`2c9b3a9044b6` in the output above) and start a new interactive shell in that container:
```shell
docker exec -it <container id> /bin/bash
# e.g., docker exec -it 2c9b3a9044b6 /bin/bash
```
You should now see a `#` prompt in the terminal, indicating that you are executing  commands in the container.  
Run the script to initialize the database and run any pending migrations
```shell
bin/rake db:setup
bin/rake db:migrate
```

### <a name='confirm-success'></a>Confirm installation success
The app should now be running. To make sure it's running, open a browser window and go to [http://localhost:8080](http://localhost:8080). You should see the user login screen, but there are no users yet in the local environment, so create one from the rails app container shell (use `docker exec -it <container id> /bin/bash`) if you need to reconnect to the rails app container
```shell
bin/rails console
```
This will open an interactive ruby session in the context of the rails app. At the ruby prompt, enter the following ruby code to create a new user (note the password :
```ruby
User.create(email: '<your email>', password: '<your password>')
```
If successful, you should see output similar to:
```ruby
=> #<User id: 1, email: "<your email>", created_at: "2023-10-01 23:00:18", updated_at: "2023-10-01 23:00:18">
```
Now, go back to the login screen in your browser and enter the email and password from the `User.create` command. You should the (empty) membership list.

## <a name='administrative-tasks'></a>Administrative Tasks
### <a name='new-user'></a>Create a new user
```ruby
User.create(email: '<your email>', password: '<your password>')
```

### <a name='new-membership-period'></a>Create a new membership year
```ruby
 MembershipPeriod.create(effective_date: 'YYYY-MM-DD', expiration_date: 'YYYY-MM-DD')
```
Typically memberships are valid from May 1st through August 31 of the following year. E.g., to create the 2023-2024 MembershipPeriod, run ` MembershipPeriod.create(effective_date: '2023-05-01', expiration_date: '2024-08-31')`.

### <a name='change-user-password'></a>Change user password
```ruby
user = User.find(email: 'user@example.com')
user.update(password: '<new password>')
```
### <a name='change-user-email'></a>Change user email
```ruby
user = User.find(email: 'user@example.com')
user.update(email: 'user@mail.example.com')
```
