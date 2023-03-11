FROM ubuntu
SHELL ["/bin/bash", "-c"]
ENV http_proxy http://172.30.0.2:9999
ENV https_proxy http://172.30.0.2:9999
RUN debconf-set-selections << "postfix postfix/mailname string traffcgen"
RUN debconf-set-selections << "postfix postfix/main_mailer_type string 'Internet Site'"
RUN apt update
RUN apt install --assume-yes postfix
RUN apt install -y mutt
RUN mkfifo /var/spool/postfix/public/pickup;
