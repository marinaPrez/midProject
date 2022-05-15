docker run --rm -d --name webserver \
           -e SERVICE_8080_NAME=webserver\
           -e SERVICE_8080_TAGS=webserver,docker \
    -p 8080:80 yeasy/simple-web:latest
