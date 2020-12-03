###############################################################################
#                               Stage 1: Build                                #
###############################################################################
FROM python:3.8.3-slim AS build

# Update and install required apt packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
            build-essential \
            libpq-dev

# Upgrade pip
RUN pip install --upgrade pip

# Build and install the production web server
RUN pip install uWSGI

# Install requirements
COPY requirements.txt .
RUN pip install -r requirements.txt

###############################################################################
#                            Stage 2: Development                             #
###############################################################################
FROM python:3.8.3-slim AS local

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    postgresql-client

# Set the working directory
WORKDIR /app

# Copy requirements from build image
COPY --from=build /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=build /usr/local/bin/ /usr/local/bin/

# Install our dev requirements
COPY requirements-dev.txt .
RUN pip install -r requirements-dev.txt

ENV PYTHONUNBUFFERED 1
ENV LANG C.UTF-8
ENV ENVIRONMENT local

EXPOSE 5000

# Entrypoint defined in config/dev-entrypoint.sh
ENTRYPOINT ["/app/config/dev-entrypoint.sh"]

# Start the development web server
CMD ["python", "manage.py", "runserver", "0.0.0.0:5000"]

###############################################################################
#                            Stage 3: Production                              #
###############################################################################
FROM python:3.8.3-slim as production

# Copy requirements from build image
COPY --from=build /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=build /usr/local/bin/ /usr/local/bin/

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    postgresql-client

WORKDIR /app

# Add our production user
RUN addgroup -gid 50101 apps && \
    useradd apps --uid 50101 --gid 50101 --home /app -M --shell /sbin/nologin

# create and chown the logs directory
RUN mkdir /logs
RUN chown apps:apps /logs

# change into our production apps user
USER apps

ENV PYTHONUNBUFFERED 1
ENV DEBUG 0
ENV LANG C.UTF-8

ENV ENVIRONMENT production

# Start the app
COPY --chown=apps:apps . /app

# Collect all the static assets to be served from /static
RUN /app/manage.py collectstatic --clear --noinput

# 3000 is the http binding, useful for troubleshooting
# 3031 is the uwsgi binding that requies a front-end (nginx)
EXPOSE 3000 3031

# Start the web server
CMD ["uwsgi", \
     "--ini", "/app/config/uwsgi.ini", \
     "--static-map", "/static=/app/api/static", \
     "--static-map", "/static=/app/api/dist/static"]
