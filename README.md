# docker-h2labs-laravel-mssql
A laravel ubuntu docker image that can connect to ms sql server

To start the container with your own laravel installation use 

docker run -d -p 80:80 -v /your/path/to/laravel/project/:/var/www/laravel/ -d laravelh2labs
