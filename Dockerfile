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
	fping \
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
	tree \
	unzip \
	vim \
	wget \
	zsh \

# Red
	arp-scan \
	dnsutils \
	host \
	iputils-ping \
	nbtscan \
	netdiscover \
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
	python-dnspython \
	python-dev \
	python3 \
	python3-pip \
	subversion \
	ruby-full \
	
# Ofensivas 
	cewl \
	hashcat \
	hydra \
	ldap-utils \
	nmap \
	netcat \ 
	nikto \
	smbclient \
	fcrackzip && \

	gem install wpscan && \
	
	apt-get update

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

# Instalar dependencias de python
COPY pip3_requirements.txt /tmp
COPY pip_requirements.txt /tmp
RUN \
	pip3 install -r /tmp/pip3_requirements.txt && \
	pip install -r /tmp/pip_requirements.txt

# Herraminetas de Desarrrollador
WORKDIR /tmp

# Instalar Go
RUN \
    wget -q https://golang.org/dl/go1.15.5.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz

ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"


## >> Herramientas de reconocimiento
FROM baseline as recon

RUN mkdir /temp
WORKDIR /temp/

RUN \
	# Instalar: aquatone
    wget --quiet https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O aquatone.zip && \
    unzip aquatone.zip -d aquatone  && \
    rm aquatone.zip  && \
	# Descargar: knock
    git clone --depth 1 https://github.com/guelfoweb/knock.git && \
	# Instalar: whatweb
	git clone --depth 1 https://github.com/urbanadventurer/WhatWeb.git 



## >> Configurar herramientas de recon
FROM builder as builder2 

	COPY --from=recon /temp/ /tools/recon/
	WORKDIR /tools/recon
	RUN \
		ln -s /tools/recon/aquatone/aquatone /usr/bin/aquatone && \
		go get github.com/OJ/gobuster && \
		go get github.com/lc/otxurls && \
		go get github.com/tomnomnom/waybackurls && \
		ln -s /tools/recon/WhatWeb/whatweb /usr/bin/whatweb

	# Instalar: Knock
	WORKDIR /tools/recon/knock
	RUN python setup.py install

## >> Descargar los Wordlists
FROM baseline as wordlists

	RUN mkdir /temp
	WORKDIR /temp/

	RUN \
		git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
		curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt && \
		curl -L -o all.txt https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt && \
		svn checkout https://github.com/daviddias/node-dirbuster/trunk/lists/ dirbuster && \
		svn checkout https://github.com/v0re/dirb/trunk/wordlists dirb


## >> Configutar las Wordlists
FROM builder2 as builder3
COPY --from=wordlists /temp/ /tools/wordlists/


## >> Instalar exploits
FROM baseline as exploits

	RUN mkdir /temp
	WORKDIR /temp/

	# aqui van exploits especificos


## >> Configurar exploits integrados
FROM builder3 as builder4

	COPY --from=exploits /temp/ /tools/exploits
	WORKDIR /tools/exploits

	
	RUN \
		# Instalar searchsploit
		git clone --depth 1 https://github.com/offensive-security/exploitdb.git /opt/exploitdb && \
		sed 's|path_array+=(.*)|path_array+=("/opt/exploitdb")|g' /opt/exploitdb/.searchsploit_rc > ~/.searchsploit_rc && \
		ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit && \
		# Install metasploit
		curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
		chmod 755 msfinstall && \
		./msfinstall && \
		msfupdate


# Personalizar S.O.

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
