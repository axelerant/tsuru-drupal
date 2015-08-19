# Drupal 7 for Tsuru

Though Tsuru is designed to run 12 factor-compatible stateless apps, it can run Drupal 7 without any hiccups.
This version runs on a modified version of the PHP platform.


## Prerequisites

1. You have created an AWS RDS instance.

2. You have deployed your ssh keys to the Tsuru instance using the `tsuru key-add` command.

3. You have installed the Tsuru client tools. If not, [follow these instructions](http://docs.tsuru.io/en/stable/using/install-client.html) and get them installed.

4. Tsuru python platform is already installed. This is needed to create the mysql-rds service app.

5. For running the one time steps, you need to have `admin` rights.

## One time steps

1. Create the Drupal platform.

```
$ tsuru-admin platform-add drupal -d https://raw.githubusercontent.com/axelerant/basebuilder/master/php/Dockerfile

``

2. Create a MySQL service on `python` platform. Note that you need to have an RDS instance running.

```
$ tsuru app-create mysql-service python

```

3. Bind the RDS instance variables to this new app.

```
$ tsuru env-set -a mysql-service MYSQL_HOST=xxx.yyy.us-east-1.rds.amazonaws.com MYSQL_USER=username MYSQL_PASSWORD=secret MYSQLAPI_DB_HOST=xxx.yyy.us-east-1.rds.amazonaws.com MYSQLAPI_DB_USER=username MYSQLAPI_DB_PASSWORD=secret MYSQLAPI_SHARED_SERVER=xxx.yyy.us-east-1.rds.amazonaws.com MYSQLAPI_SHARED_USER=username MYSQLAPI_SHARED_PASSWORD=secret

```

4. Deploy the MySQL service app.


```
$ cd path/to/mysql/service

$ git remote add aws git@10.2.3.4.nip.io:mysql-service.git

$ git push aws master

```

5. Create a new service using `crane`.

```
$ cd path/to/mysql/service

$ crane create service.yml

```

6. your service list should now contain a MySQL RDS service.

```
$ tsuru service-list

+-----------+-----------+
| Services  | Instances |
+-----------+-----------+
| mysql-rds |           |
+-----------+-----------+

```

## Creating new Drupal apps

1. Clone/fork this repo.

```
$ git clone git@github.com:axelerant/tsuru-drupal.git

```

2. Create a new app, say `drupal7` under the `drupal` platform.

```
$ tsuru app-create drupal7 drupal

```

3. Create a new service for this app.

```
$ tsuru service-add mysql-rds drupal7

```

4. Bind this service to the app.

```
$ tsuru service-bind drupal7 -a drupal7

```

5. All the DB details are bound to environmental variables and need no editing in `settings.local.php`. No editing whatsoever happens in `settings.php` except for including the above file.

```
$ tsuru env-get -a drupal7
MYSQL_DATABASE_NAME=*** (private variable)
MYSQL_HOST=*** (private variable)
MYSQL_PASSWORD=*** (private variable)
MYSQL_PORT=*** (private variable)
MYSQL_USER=*** (private variable)
TSURU_APPDIR=*** (private variable)
TSURU_APPNAME=*** (private variable)
TSURU_APP_TOKEN=*** (private variable)
TSURU_HOST=*** (private variable)
TSURU_SERVICES=*** (private variable)

```

6. Deploy this app.

```
$ cd path/to/drupal/app

$ git remote add aws git@10.2.3.4.nip.io:drupal7.git

$ git push aws master

```

7. All set!


## Configurable stuff

1. **tsuru.yml.** Edit this if you are deploying using nginx, enabling new module in apache, running a custom command after each deployment(ex. the famous `drush cc all` command). [More docs here](https://github.com/axelerant/basebuilder/tree/master/php)

2. **build.sh** script which does the first time stuff/booting for Drupal. If you want to install a custom profile, create new users/roles, enable custom modules etc, change this. There are many environment variables in this script which can be set using `tsuru env-set` command before deploy to take effect. Ex: profile name, admin password, extra `drush site-install` options etc.

3. You can change drush version and add other libraries(if any) in **composer.json**.

4. **sites/default/settings.local.php** settings specific to this setup go here.


## Persistent files

How do we persist files in Docker containers? They are ephermeral and disappear after every deploy right?
Thanks to Tsuru's `sharedfs` configuration, `sites/default/files` gets stored in `/shared` in container, which mounts at `/apps-data/<app-name>` in host.

**Note** The `sites/default/files` directory is linked to `/shared` during deploy.

1. If you are running a stock Tsuru setup, make the following changes to `/etc/tsuru/tsuru.conf` under the `docker` section.

```
  sharedfs:
    hostdir: /apps-data
    mountpoint: /shared
    app-isolation: true

```

2. Restart the API server for these changes to take effect

```
$ sudo service tsuru-server-api restart

```

**Note** These changes should be done before deploying your first Drupal app, ideally after creating the `drupal` platform.


## TODO

1. Make persistent files work across nodes.

2. Drush aliases/ssh access.

3. Importing existing sites.

4. Debugging/logs command similar to Heroku.

## Contact

Patches/comments/criticism/issues are welcome.

[@lakshminp](https://twitter.com/lakshminp)
