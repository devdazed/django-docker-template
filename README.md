# Django Docker Template
This is a template for starting up development in django using Docker, Docker Compose, and Django with Postgres, 
and Redis

## Development
To start development first copy the environment file locally and edit any of the values, the default should work 
if you are using a standard docker-compose based development environment
```bash
cp .env.example .env
```

Next bring up the environment
```bash
docker-compose up
```

If this is the first time bringing up the environment, or you need to run migrations:
```bash
docker-compose exec app python manage.py migrate
```

If this is the first time bringing up the environment, to create a superuser:
```bash
docker-compose exec app python manage.py createsuperuser
```

### Running Tests
To run tests simply run:
```
docker-compose run app python manage.py test
```

If you would like coverage to be reported as part of the test run then run the following:
```
docker-compose run app bash -c "coverage run manage.py test && coverage report"
```

or for HTML based coverage reporting
```
docker-compose run app bash -c "coverage run manage.py test && coverage html -d htmlcov"
```

### Notebooks
To use the notebooks, navigate to `http://localhost:8888`. The password to log into the notebooks is
`password`

Once in Jupyter create a new `Django Shell-Plus` notebook to use jupyter as a Django cli replacement.

### Using the admin
Once you have created a superuser, log into the admin by browsing to `http://localhost:5000/admin`

### Sample app
There's a sample app called `health` it just responds with `{"health":"healthy"}` but is designed to show how to add
additional apps to the Django application.

### Production
Currently, the Dockerfile is set up to run as wsgi in production, this would require using a front-end web server like 
NGINX feel free to update the Production section of the dockerfile to fit your needs.
