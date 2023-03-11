FROM ubuntu
RUN debconf-set-selections << "postfix postfix/mailname string traffcgen"
RUN debconf-set-selections << "postfix postfix/main_mailer_type string 'Internet Site'"
RUN apt install --assume-yes postfix
RUN apt install mutt;
RUN mkfifo /var/spool/postfix/public/pickup;
