# darrenhoyland_info_stack


## Deployment

Deployment method swiped from  https://github.com/mikegcoleman/todo (https://www.youtube.com/watch?v=z525kfneC6E)

### AWS Lightsail Launch script

        curl -o lightsail.sh https://raw.githubusercontent.com/autonomouse/darrenhoyland_info_stack/master/lightsail-compose.sh

        chmod +x ./lightsail.sh

        ./lightsail.sh

### Local Deployment via Docker-compose

        docker-compose up
