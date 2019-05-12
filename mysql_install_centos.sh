#!/bin/bash

#[ref]
#https://www.linode.com/docs/databases/mysql/how-to-install-mysql-on-centos-7/#install-mysql

# 清理CentOS7下的MariaDB
rpm -qa | grep mariadb
# mariadb-libs-5.5.56-2.el7.x86_64 是查询出来的rpm包
rpm -e --nodeps mariadb-libs-5.5.56-2.el7.x86_64

# 下载Mysql的yum包
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
# 查看当前可用的Mysql安装资源
yum repolist enabled | grep "mysql.*-community.*"

# 安装Mysql,若没有错误发生，按y
yum install mysql-server
# 设置开机启动
systemctl enable mysqld
# 启动Mysql服务
systemctl start mysqld

# 安装完毕后配置
# 在/etc/my.cnf [mysqld]下，添加bind-address=0.0.0.0
# 安全设置
mysql_secure_installation
# 根据提示设置：
# 1. 要求root用户当前密码，直接回车不输入任何值
# 2. 要求重新设置root密码，输入y，并输入root用户密码
# 3. 要求删除匿名用户，输入y，删除
# 4. 要求禁止root远程登录，输入y
# 5. 要求删除test测试数据库，输入y
# 6. 要求刷新权限，输入y
 
