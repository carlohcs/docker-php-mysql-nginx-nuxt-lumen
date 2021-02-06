# docker-php-mysql-nginx-nuxt-lumen
Two applications: backend (with PHP/MySQL/Lumen) and frontend (Nuxt.js) with routes managed by Nginx.

## Usage

In your docker file:

```
FROM carlohcs/php-mysql-nginx-nuxt-lumen:latest

... your code
```

ATTENTION: Don't forget to create a folder with the structure:

```
rootFolder
    - front
        - nuxtjs folders and files
        - nuxt dist folder
    - back
        - lumen folders and files
    - config
        - a copy of config folder at this repository

```

## Running

```
docker build --progress=tty -t CONTAINER_NAME .
```

In the final, access http://localhost