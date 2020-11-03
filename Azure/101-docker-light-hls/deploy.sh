docker build -t flecoqui/my-first-repo .
docker run -p 80:80/tcp  -p 8080:8080/tcp   -p 1935:1935/tcp  flecoqui/my-first-repo
docker push flecoqui/my-first-repo