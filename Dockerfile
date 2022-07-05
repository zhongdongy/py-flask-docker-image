#
# An image for building Flask Docker base image
# the image can be used for running Flask applications (as well as a Unix sock)
#
# Author: Zhongdong Yang
# Email: zhongdong_y@outlook.com
# Copyright: Zhongdong Yang
# Date: 2022-07-05
#

FROM ubuntu:focal
USER root

WORKDIR /app

# ===
# Add all locales and set en_US.utf8 as default
# ===
RUN apt-get update \
  && apt-get -y install ca-certificates software-properties-common curl dos2unix
COPY config/sources.list /etc/apt/sources.list
COPY config/cert/deadsnakes /tmp/deadsnakes
COPY config/deadsnakes-ubuntu-ppa-focal.list /etc/apt/sources.list.d/deadsnakes-ubuntu-ppa-focal.list
RUN apt-key add /tmp/deadsnakes
RUN apt-get update && apt-get install -y locales apt-transport-https
RUN rm -rf /var/lib/apt/lists/*
RUN localedef -i en_US -c -f UTF-8 \
  -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# ==
# Install required softwares
# ==
# 1. OpenResty
RUN apt-get update && apt-get -y install build-essential wget gnupg vim net-tools
RUN wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
RUN echo "deb http://openresty.org/package/ubuntu focal main" \
  | tee /etc/apt/sources.list.d/openresty.list
RUN apt-get update && apt-get -y install openresty

# 2. Python 3.10.x
RUN apt-get update && apt-get -y install software-properties-common
RUN apt-get update && apt-get -y install python3.10 python3.10-distutils python3.10-dev
RUN unlink /usr/bin/python3
RUN ln -s /usr/bin/python3.10 /usr/bin/python3
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3


# 3. supervisor + uwsgi
RUN python3 -m pip install supervisor
RUN python3 -m pip install uwsgi

# ==
# Update configurations and copy files
# ==
COPY config/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/uwsgi.yml /app/uwsgi.yml
COPY config/nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY config/nginx/sites /usr/local/openresty/nginx/sites
COPY script/startup.sh /app/startup.sh
COPY html /app/html
COPY ./flask_app.py /app/flask_app.py
COPY ./main.py /app/main.py
COPY ./sock.py /app/sock.py
COPY ./requirements.txt /app/requirements.txt
RUN python3 -m pip install -r /app/requirements.txt
RUN mkdir -p /var/log/openresty/
RUN mkdir -p /var/log/supervisord/
RUN dos2unix /app/startup.sh
RUN dos2unix /app/uwsgi.yml
RUN chmod +x /app/startup.sh
WORKDIR /app
ENTRYPOINT ["./startup.sh"]
