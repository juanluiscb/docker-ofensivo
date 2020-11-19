# docker-ofensivo

## Objetivo 

El objetivo es crear una imagen docker con las herramientas básicas necesarias para hacer un pentest, que inicialmente pueda correr localmente.

## Construir la imagen con el Dockerfile

~~~
docker build -t docker-ofensivo .
~~~

## Casos de Uso

Una vez que tienes la imagen del docker ofensivo (por ahora deberás construirla en base al Dockerfile), puedes ejecutar el contenedor docker ofensivo para empezar a utilizar las herramientas, de acuerdo a tus necesidades.

### Ejecutar el contenedor para usar las herramientas instaladas

~~~~
docker run --rm -it --name ofensivo docker-ofensivo /bin/zsh
~~~~

### Ejecutar el contenedor con soporte para archivos vpn (hackthbox, tryhackme, etc)

- Levantar el contenedor 
~~~~
docker run --rm -it --name ofensivovpn --cap-add=NET_ADMIN --device=/dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0  -v /Users/castr/hack/ofensivo:/ofensivo docker-ofensivo /bin/zsh
~~~~
- Conectarse al contenedor
~~~
docker exec -i -t ofensivovpn /bin/zsh
~~~


Notas: 
- Los archivos de conexión a vpn (.ovpn) se guardan de manera local y se ponene disponibles usando un volumén


## Cosas por hacer
- Automatizar la creación del VPS en la nube con terraform
- Aprovisionar el servidor con ansible
- Desplegar el contenerdor en el VPS en la nube
- Se aceptan sugerencias