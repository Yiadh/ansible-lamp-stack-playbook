if [[ "$1" == "build" ]]; then
  docker rmi -f sshd
  docker build -t sshd .
elif [[ "$1" == "stop" ]]; then
  docker stop loadbalancer_container webserver1_container webserver2_container database_container
elif [[ "$1" == "start" ]]; then
  docker start loadbalancer_container webserver1_container webserver2_container database_container
elif [[ "$1" == "run" ]]; then
  echo "Creating docker network, so all containers will see each other"
  docker network create --subnet=172.19.0.0/16 lamp
  echo "Starting loadbalancer container"
  docker run -d --net lamp \
    --hostname loadbalancer \
    --name loadbalancer_container \
    --publish 2200:22 \
    --ip 172.19.0.2 \
    sshd:latest
  echo "Starting webserver1 container"
  docker run -d --net lamp \
    --hostname webserver1 \
    --name webserver1_container \
    --publish 2201:22 \
    --ip 172.19.0.3 \
    sshd:latest
  echo "Starting webserver2 container"
  docker run -d --net lamp \
    --name webserver2_container \
    --hostname webserver2 \
    --publish 2202:22 \
    --ip 172.19.0.4 \
    sshd:latest
  echo "Starting database container"
  docker run -d --net lamp \
    --name database_container \
    --hostname database \
    --publish 2203:22 \
    --ip 172.19.0.5 \
    sshd:latest
elif [[ "$1" == "clean" ]]; then
  docker rm -f loadbalancer_container
  docker rm -f webserver1_container
  docker rm -f webserver2_container
  docker rm -f database_container
  docker network remove lamp
else
  echo "action not supported"
fi
