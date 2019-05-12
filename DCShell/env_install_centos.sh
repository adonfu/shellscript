#!/bin/bash

hostnamectl set-hostname "name"
# install lsb_release
yum install -y redhat-lsb

yum update
yum install wget
yum install unzip
# install git
yum install git-core
# install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py

# 安装Mysql-python模块
yum install python-devel
yum install libevent-devel
yum -y install mysql-devel
yum install gcc libffi-devel python-devel openssl-devel -y
easy_install gevent

wget https://pypi.python.org/packages/a5/e9/51b544da85a36a68debe7a7091f068d802fc515a3a202652828c73453cad/MySQL-python-1.2.5.zip#md5=654f75b302db6ed8dc5a898c625e030c
unzip MySQL-python-1.2.5.zip
cd MySQL-python-1.2.5/
python setup.py build
python setup.py install

# 安装依赖包
pip install tornado
pip install requests
pip install redis
pip install torndb
pip install rsa

# 启动8212端口，文件服务
nohup python -m SimpleHTTPServer 8212 &
