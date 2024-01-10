This folder contains examples for building emulators from scratch on Alpine and Debian Linux.

### 1. Prerequisites

Check that you have docker installed and set up on your user.

```sh
which docker
docker run hello-world
```

If that didn't work then you are probably lacking the permission to use docker. Try this:
```sh
groups YOURUSERNAMEHERE
usermod -aG docker YOURUSERNAMEHERE
newgrp docker
```

### 2. Running builds in docker

If everything is working, then build some emulators using the dockerfiles! Use --progress=plain for more verbose output.
 
```sh
cd dockerfiles
docker build . --progress=plain -f Dockerfile.bizHawk-debian
```


