# dockerized-php-rails-postgres
Quickly spin up dockerized development environment that support PHP api and Postgres database. Ruby on Rails is installed on api node to support `rake db:migrate` commands and deployment to production environment.

I make this to replace Vagrant & VirtualBox setup which made my laptop fan runs like crazy. Besides, Docker images use less storage as it only install the necessary packages to run the app. The main benefits of this setup include but not limited to:

- Fast, simple, flexible and lightweight.
- Easily spin up any development environment without the hurdle of OS barrier.
- PHP debug using XDebug integration with Visual Studio Code.

## Prerequisite
- [Docker](http://docker.com) (**mandatory**) is a set of platform as a service products that use OS-level virtualization to deliver software in packages called containers. Containers are isolated from one another and bundle their own software, libraries and configuration files; they can communicate with each other through well-defined channels. Docker Desktop can be downloaded from: https://www.docker.com/products/docker-desktop
- [Visual Studio Code](https://code.visualstudio.com) (*optional to support php debug and highly recommend*) is a free source-code editor made by Microsoft for Windows, Linux and macOS. Features include support for debugging, syntax highlighting, intelligent code completion, snippets, code refactoring, and embedded Git.

## Quick start
To quickly spin up, run the following command:
```bash
mkdir ./my_development_site
cd ./my_development_site
git clone https://github.com/kai-uofa/dockerized-php-rails-postgres.git
cd ./dockerized-php-rails-postgres
chmod +x ./dev_bootstrap.sh
./dev_bootstrap.sh 'DATABASE_BACKUP_PATH' 'RAIL_GIT_URL' 'RAIL_BRANCH' 'API_GIT_URL' 'API_BRANCH' 'RUBY_VERSION' 'RUBY_RAIL_GEMSET' 'RUBY_API_GEMSET'
```
where the variables are:
- DATABASE_BACKUP_PATH: path or url to database *.gz backup file
- RAIL_GIT_URL: Rails git repository
- RAIL_BRANCH: Rails branch you want to clone
- API_GIT_URL: PHP api git repository
- API_BRANCH: PHP api branch you want to clone
- RUBY_VERSION: Ruby version (default: 2.4.9)
- RUBY_RAIL_GEMSET: RVM gemset name for Rails repository
- RUBY_API_GEMSET: RVM gemset name for PHP api repository (this support deployment to production environment from within PHP api docker)

To stop running services, use the following commands:
```bash
cd ./my_development_site # if youare not in this folder yet
docker-compose stop
```

To start existing services, use the following command:
```bash
cd ./my_development_site # if youare not in this folder yet
docker-compose start
```

**Some tips while using this setup**: 
- You can run `dev_bootstrap.sh` without passing params too but you need to make sure you have your Rails and PHP repositories available locally at default locations. Please check the **Notes** section below for more information about directory structure. Other than that, this dockerized environment should spin up normally with an empty Postgres database named `example_db`.
- If you have Visual Studio Code, you should install the [Docker extension](https://code.visualstudio.com/docs/containers/overview) for better management.
- If you would like to know more about Docker and Docker-compose, check out this [cheatsheet](https://dockerlabs.collabnix.com/docker/cheatsheet/)

## PHP debug with Visual Studio Code, Xdebug & Docker
1. Once you install Visual Studio Code, click on the Extensions icon on the left and install the [PHP Debug](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug) and [PHP IntelliSense](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-intellisense) extensions from Felix Becker. Strictly speaking, you can debug without the PHP IntelliSense extension, but it’s very nice to have.
2. Only on Windows, you need to install PHP locally. The Visual Studio Code extensions mentioned above rely upon PHP running locally on Windows, your application code will not be using this version of PHP. If you don’t have PHP on Windows already, download the most current PHP Non Thread Safe version from [php.net](https://windows.php.net/download/). Add the directory containing `php.exe` to your path. Make sure you can run `php -version` from a new command prompt.
3. You will need to create a debugging task for PHP. In Visual Studio Code, pull down the Debug menu and select `Add Configuration`. If you have the PHP Debug extension installed, you will have an option in the list for PHP. By default, there are two entries created. The first, `Listen for XDebug` is the one you’ll need. The second, `Launch currently open script` you will not use, at least here. Please play attention to these points:
   - The port number has to match what’s in your XDEBUG_CONFIG set up in your `docker-compose.yaml` file.
   - The path mappings need to be correct. Do not use drive letters, do not use relative paths, or anything other than `${workspaceFolder}` to map to your files.
   - The other `xdebugSettings` are put in to help ensure that I can drill down when inspecting arrays and such. You can tweak these values to your liking.
4. You will want to update the `.vscode/launch.json` file inside your PHP workspace as follows. Running `dev_bootstrap.sh` will do this for you as well.
   ```json
   {
      // Use IntelliSense to learn about possible attributes.
      // Hover to view descriptions of existing attributes.
      // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
      "version": "0.2.0",
      "configurations": [
          {
              "name": "Listen for XDebug",
              "type": "php",
              "request": "launch",
              "port": 9000,
              "log": true,
              "pathMappings": {
                  "/var/www/html": "${workspaceFolder}"
              },
              "xdebugSettings": {
                  "max_data": 65535,
                  "show_hidden": 1,
                  "max_children": 100,
                  "max_depth": 5
              }
          }
      ]
    }
   ```

## Notes
- Services' environment variables are defined in `*.env` files within `env-variables` folder, you might need to change them to suite your need.
- Docker-compose's environment variables are generated during bootstrapping process, you might want to check the files to change these variables.
- It's best to create a "development site" folder as this tools is setup in a self contain mindset. Each code base will be in it's own folder.
  ```bash
    cd ./my_development_site
    tree -v -L 1 --charset utf-8
    .
    ├── dockerized-php-rails-postgres
    ├── php-api
    ├── postgres-data
    └── rails
  ``` 

## References
- https://docs.docker.com/compose/rails/
- https://www.codewithjason.com/dockerize-rails-application/
- https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development
- https://github.com/chrisf/rails-postgres-docker
- https://medium.com/@jasonterando/debugging-with-visual-studio-code-xdebug-and-docker-on-windows-b63a10b0dec
- https://dev.to/jonesrussell/install-composer-in-custom-docker-image-3f71
- https://stackoverflow.com/questions/41274829/php-error-the-zip-extension-and-unzip-command-are-both-missing-skipping