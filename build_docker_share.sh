# dind oficial
# https://hub.docker.com/_/docker
docker buildx build -f Dockerfile_sshx -t docker_share .
docker run -it --rm -v ./:/code docker_share
