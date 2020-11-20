# dockerized-php-rails-postgres

Quickly spin up dockerized development environment that support PHP api and Postgres database. Ruby on Rails is installed on api node to support `rake` commands and deployment to production environment.

I make this to replace Vagrant & VirtualBox setup which made my laptop fan runs like crazy. Besides, Docker images use less storage as it only install the necessary packages. The main benefits of this setup include but not limited to:

- Fast, simple, flexible and lightweight.
- Easily spin up any development environment without the hurdle of OS barrier.
- PHP debug integration with Visual Studio Code out of the box.

## Prerequisite

- [Docker](http://docker.com) (**mandatory**) is a set of platform as a service products that use OS-level virtualization to deliver software in packages called containers. Containers are isolated from one another and bundle their own software, libraries and configuration files; they can communicate with each other through well-defined channels. Docker Desktop can be downloaded from: https://www.docker.com/products/docker-desktop
  
- [Visual Studio Code](https://code.visualstudio.com) (*optional to support php debug*) is a free source-code editor made by Microsoft for Windows, Linux and macOS. Features include support for debugging, syntax highlighting, intelligent code completion, snippets, code refactoring, and embedded Git.

## Quick start
To quickly spin up, run the following command:
```bash
mkdir ./my_development_site
cd ./my_development_site
git clone https://github.com/kai-uofa/dockerized-php-rails-postgres.git
cd ./dockerized-php-rails-postgres
chmod +x ./dev_bootstrap.sh
./dev_bootstrap.sh 'RAIL_GIT_URL' 'API_GIT_URL' 'DATABASE_BACKUP_PATH' 'RUBY_VERSION' 'RUBY_RAIL_GEMSET' 'RUBY_API_GEMSET'
```
where the variables are:

- RAIL_GIT_URL: Rails git repository
- API_GIT_URL: PHP api git repository
- DATABASE_BACKUP_PATH: path or url to database *.gz backup file
- RUBY_VERSION: Ruby version (eg. 2.4.9)
- RUBY_RAIL_GEMSET: RVM gemset name for Rails repository
- RUBY_API_GEMSET: RVM gemset name for PHP api repository (this support deployment to production environment from within PHP api docker)

## Notes
- Services' environment variables are defined in `*.env` files within `env-variables` folder, you might need to change them to suite your need.
- Docker-compose's environment variables are generated during bootstrapping process, you might want to check the files to change these variables.
- It's best to create a "development site" folder as this tools is setup in a self contain mindset. Each code base will be in it's own folder.
  ```bash
    cd ./my_development_site
    tree -v -L 1 --charset utf-8
    .
    ├── my_development_site.code-workspace
    ├── dockerized-php-rails-postgres
    ├── php-api
    ├── postgres-data
    └── rails

    4 directories, 1 file
  ``` 
## References
- https://docs.docker.com/compose/rails/
- https://www.codewithjason.com/dockerize-rails-application/
- https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development
- https://github.com/chrisf/rails-postgres-docker
- https://medium.com/@jasonterando/debugging-with-visual-studio-code-xdebug-and-docker-on-windows-b63a10b0dec
- https://dev.to/jonesrussell/install-composer-in-custom-docker-image-3f71
- https://stackoverflow.com/questions/41274829/php-error-the-zip-extension-and-unzip-command-are-both-missing-skipping