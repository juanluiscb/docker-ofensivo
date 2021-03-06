# docker-ofensivo

Es una imagen de docker con las herramientas más usadas para pruebas de penetración o pentest, para ser desplegada fácil y rápidamente.

## Tabla de Contenido
- [Requerimientos](#requerimientos)
- [Como usar](#como-usar)
- [Cosas por haceer](#cosas-por-hacer)

## Requerimientos
- Tener instalado el servicio de docker



## Como usar

### Construir la imagen con el Dockerfile

~~~
docker build -t docker-ofensivo .
~~~

### Casos de Uso

Una vez que tienes la imagen del docker ofensivo (por ahora deberás construirla en base al Dockerfile), puedes ejecutar el contenedor docker ofensivo para empezar a utilizar las herramientas, de acuerdo a tus necesidades.

#### Ejecutar el contenedor para usar las herramientas instaladas:

~~~~
docker run --rm -it --name ofensivo docker-ofensivo /bin/zsh
~~~~

#### Ejecutar el contenedor con soporte para archivos vpn (hackthbox, tryhackme, etc):

- Levantar el contenedor 
~~~~
docker run --rm -it --name ofensivovpn --cap-add=NET_ADMIN --device=/dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0  -v /Users/castr/hack/ofensivo:/ofensivo docker-ofensivo /bin/zsh
~~~~
- Una vez dentro del contenedor, conectarse a la vpn deseada, usando los alias en shell/alias
~~~
vpnhtb  
vpntry
~~~
Nota:
- Tener en cuenta que los archivos de conexión de la vpn se comparten con el contenedor de la máquina local (/User/castr/hack/ofensivo)

#### Ejecutar el contenedor con sporte vpn y proxy squid y apache (puertos 3128 y 80):

Si deseas poder acceder a los puertos http/https/ftp de las máquinas dentro de la vpn lo puedes hacer através del proxy squid, también tendrás un servidor web local corriendo dentro del contenedor.

- Levantar el contenedr
~~~
docker run --rm -it --name ofensivovpn --cap-add=NET_ADMIN --device=/dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0  -v /Users/castr/hack/ofensivo:/ofensivo -p 3128:3128 -p 80:80 docker-ofensivo /bin/zsh
~~~

- Una vez dentro del contenedor, arrancar squid y/o apache de acuerdo a las necesidades, usando los alias en shell/alias
~~~
squidUP
apacheUP
~~~ 

## Cosas por hacer
- Automatizar la creación del VPS en la nube con terraform
- Aprovisionar el servidor con ansible
- Desplegar el contenerdor en el VPS en la nube
- Se aceptan sugerencias