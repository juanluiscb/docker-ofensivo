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
	p7zip-full \
	ssh \
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

# >> Servicios

FROM baseline as builder

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

COPY shell/ /tmp

# Personalizar

RUN \
	# Banner
	cat /tmp/banner >> /root/.zshrc && \
	# Crear accesos rapidos
	cat /tmp/alias >> /root/.zshrc 

WORKDIR /
