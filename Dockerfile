FROM ubuntu as baseline

LABEL maintainer="hackadvisermx" email="hackadviser@gmail.com"

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

# >> Instalar paquetes

RUN \

# Sistema
    apt-get update && \
    apt-get install -y \
	apache2 \
	chromium-browser \
	curl \
	figlet \
	ftp \
	htop \
	jq \
	locate \
	nano \
	p7zip-full \
	squid \
	ssh \
	tmux \
	traceroute \
	unzip \
	vim \
	wget \
	zsh \

# Red
	dnsutils \
	host \
	iputils-ping \
	net-tools \
	openvpn \
	tcpdump \
	traceroute \
	telnet \
	whois \

# Desarrollo
	git \
	nodejs \
	openjdk-8-jdk \
	php \
	python \
	python-dev \
	python3 \
	python3-pip \
	ruby-full \
	
# Ofensivas 
	cewl \
	hashcat \
	hydra \
	nmap \
	netcat \ 
	nikto \
	smbclient \
	fcrackzip 
	#apt-get update

# Instalar python-pip
RUN curl -O https://raw.githubusercontent.com/pypa/get-pip/master/get-pip.py &&  \
    python get-pip.py  && \
    echo "PATH=$HOME/.local/bin/:$PATH" >> ~/.bashrc && \
    rm get-pip.py



# >> Servicios

FROM baseline as builder

RUN \

# Configuracion de Apache
	sed -i 's/Si Funciona!/Funciona desde el contenedor!/g' /var/www/html/index.html && \	

# Configuracion de Squid
	echo "http_access allow all" >> /etc/squid/squid.conf && \
    	sed -i 's/http_access deny all/#http_access deny all/g' /etc/squid/squid.conf && \

# Instalar oh-my-sh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i '1i export LC_CTYPE="C.UTF-8"' /root/.zshrc && \
    sed -i '2i export LC_ALL="C.UTF-8"' /root/.zshrc && \
    sed -i '3i export LANG="C.UTF-8"' /root/.zshrc && \
    sed -i '3i export LANGUAGE="C.UTF-8"' /root/.zshrc && \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search /root/.oh-my-zsh/custom/plugins/zsh-history-substring-search && \
    sed -i 's/plugins=(git)/plugins=(git aws golang nmap node pip pipenv python ubuntu zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/g' /root/.zshrc && \
    sed -i '78i autoload -U compinit && compinit' /root/.zshrc


# Instalar Go
RUN \
    wget -q https://golang.org/dl/go1.15.5.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz

ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"


# >> Recon
RUN \
	go get github.com/OJ/gobuster && \
	go get github.com/ffuf/ffuf 


# Personalizar 

COPY shell/ /tmp


RUN \
  # Banner
	cat /tmp/banner >> /root/.zshrc && \
  # Crear accesos rapidos personalizados 
	cat /tmp/alias >> /root/.zshrc && \
  # Crear funciones personalizadas
	cat /tmp/funciones >> /root/.zshrc && \
  # Configuracion tmux
	cp /tmp/.tmux.conf /root && \
  # Actualizar la base de datos de archvios locales
	updatedb

WORKDIR /
