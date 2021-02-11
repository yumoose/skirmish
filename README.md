# Skirmish

<img src="https://skirmish.online/dist/images/logo-dark.svg" width="200px" height="200px" alt="Skirmish logo">

[![CircleCI](https://circleci.com/gh/yumoose/skirmish.svg?style=svg)](https://circleci.com/gh/yumoose/skirmish)
[![dependencies](https://david-dm.org/yumoose/skirmish.svg)](https://david-dm.org/yumoose/skirmish)
[![Using Amber framework](https://img.shields.io/badge/using-amber_framework-orange.svg)](https://amberframework.org)

## Getting Started

These instructions will get a copy of this project running on your machine for development and testing purposes.

## Prerequisites

This project requires [Crystal](https://crystal-lang.org/)
The version of Crystal used is defined inside `.crystal-version`.
I'd recommend using [crenv](https://github.com/pine/crenv) to install the current version of Crystal, which is as simple as the following command inside the project folder.

```shell
crenv install
```

There are also some other dependencies required for some extensions of Crystal and Amber, as well as PostgresQL.

<details><summary>For Ubuntu</summary>

```shell
sudo apt install -y postgresql libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev libevent-dev libsqlite3-dev redis-server
```
</details>

<details><summary>For OSX</summary>

```shell
brew tap amberframework/amber
brew install amber
brew install postgresql
```
</details>

### Postgres
Unless you've used Postgres before, or know your way around configuring it already, you'll probably want to follow this quick guide to setting up users for development.

<details><summary>Postgres Quickstart</summary>

### User creation
<details><summary>For Ubuntu</summary>

```shell
# start a session as the postgres user
sudo su - postgres;

# create a user named postgres if it doesn't already exist
create user skirmish;

# then grant it super user access
alter user skirmish with superuser;

# optionally create a user to login to postgres yourself
create user <username> --pwprompt;

# exit the session as postgres
exit
```
</details>

<details><summary>For OSX</summary>

```shell
# start a session as the postgres user
psql postgres

# create a user named postgres if it doesn't already exist
create user skirmish;

# then grant it super user access
alter user skirmish with superuser;

# exit the session as postgres
exit
```
</details>

### Authentication configuration
To change the authentication with postgres to use a simple password 'trust' authentication method, we'll need to edit the `pg_hba.conf` file.

<details><summary>For Ubuntu</summary>

```shell
sudo vim /etc/postgresql/10/main/pg_hba.conf
```
</details>

<details><summary>For OSX</summary>

```shell
vim /usr/local/var/postgres/pg_hba.conf
```
</details>

Replace `md5` with `trust` on the lines for local connections
```shell
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
```

### Restarting the Postgres service

And finally, ensure the settings for postgres have been applied by restarting the service

<details><summary>For Ubuntu</summary>

```shell
sudo service postgresql restart
```
</details>

<details><summary>For OSX</summary>

```shell
brew services restart postgresql
```
</details>

</details>

## Development

To start your Amber server (Both Linux and Mac):

```shell
# update the development environment settings to your liking
cp config/environments/development.yml.example config/environments/development.yml
cp config/environments/test.yml.example config/environments/test.yml

shards install                # install dependencies
shards build                  # build executable binaries
crystal ./src/sam.cr db:setup # create the database and bring it up to speed
bin/amber db seed             # optionally seed the database with some mock data
bin/amber watch               # start the server and watch for file changes
```

Now you can visit http://localhost:3000/ from your browser.

## Tests

To run the test suite:

```shell
crystal spec
```

## Possible Installation Issues
<details><summary>WSL 1</summary>
Services need manual startup

```
sudo service postgresql restart
redis-server &
```
</details>
<details><summary>Amber server.bind_ssl</summary>

Some setups are hitting undefined `bind_ssl` method errors within Amber itself. The good news is that we don't actually need it.

```crystal
Error in src/skirmish.cr:3: instantiating 'Amber::Server:Class#start()'

Amber::Server.start
              ^~~~~

in lib/amber/src/amber/server/server.cr:17: instantiating 'Amber::Server#run()'

      instance.run
               ^~~

in lib/amber/src/amber/server/server.cr:50: instantiating 'start()'

        start
        ^~~~~

in lib/amber/src/amber/server/server.cr:62: undefined method 'bind_ssl' for HTTP::Server

        server.bind_ssl Amber.settings.host, Amber.settings.port, ssl_config, settings.port_reuse
               ^~~~~~~~

Rerun with --error-trace to show a complete error trace.
```

### Resolution
Open the breaking file `/skirmish/lib/amber/src/amber/server/server.cr`

And comment out lines 60-63 and 65

```crystal
#  if ssl_enabled?
#    ssl_config = Amber::SSL.new(settings.ssl_key_file.not_nil!, settings.ssl_cert_file.not_nil!).generate_tls
#    server.bind_ssl Amber.settings.host, Amber.settings.port, ssl_config, settings.port_reuse
#  else
    server.bind_tcp Amber.settings.host, Amber.settings.port, settings.port_reuse
#  end
```
</details>

## Contributing
1. Fork it
2. Create your feature branch ( `git checkout -b my-new-feature` )
3. Commit your changes ( `git commit -am 'Add some feature'` )
4. Push to the branch ( `git push origin my-new-feature` )
5. Create a new Pull Request

## Contributors
- [yumoose](https://github.com/yumoose) | Jordane Lew
- [nandahibatullah](https://github.com/nandahibatullah) | Nanda Hibatullah
- [richardmcmillen](https://github.com/richardmcmillen) | Ricky McMillen
- [HookyQR](https://github.com/HookyQR)
- [Dhamsoft](https://github.com/Dhamsoft) | Dhamodharan
