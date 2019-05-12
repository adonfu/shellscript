#!/bin/bash

yum -y install gcc gcc-c++ libstdc++-devel

instPath="/root/redis/"
instFile="/root/redis/redis-4.0.9.tar.gz"

if [ ! -d "$instPath" ];then
mkdir -p "$instPath"
fi

if [ ! -f "$instFile" ];then
wget -P "$instPath" http://download.redis.io/releases/redis-4.0.9.tar.gz
fi
tar -xzvf "$instFile" -C /usr/local/src/

redisSrcDir="/usr/local/src/redis-4.0.9/"
if [ ! -d "$redisSrcDir" ];then
echo "tar command exec error!"
exit
fi

redisServerDir="/usr/local/redis/"

make -C /usr/local/src/redis-4.0.9/ MALLOC=libc 
make PREFIX="$redisServerDir" -C /usr/local/src/redis-4.0.9/ install

mkdir -p /usr/local/redis/etc/
cp /usr/local/src/redis-4.0.9/redis.conf /usr/local/redis/etc/

cp /usr/local/redis/bin/redis-benchmark /usr/bin/
cp /usr/local/redis/bin/redis-cli /usr/bin/
cp /usr/local/redis/bin/redis-server /usr/bin/

# 修改配置文件
redisCfgFile="/usr/local/redis/etc/redis.conf"
sed -i 's/#bind 127.0.0.1/bind 127.0.0.1/g' "$redisCfgFile"
sed -i 's/daemonize no/daemonize yes/g' "$redisCfgFile"
sed -i 's/protected-mode no/protected-mode yes/g' "$redisCfgFile"
sed -i '/# requirepass foobared/a\requirepass fooredis' "$redisCfgFile"
sed -i 's/timeout 0/timeout 300/g' "$redisCfgFile"

#配置环境变量
echo 'export PATH="$PATH:/usr/local/redis/bin"' >> /etc/profile
source /etc/profile

# 启动脚本
cat>/etc/init.d/redis<<EOF
#!/bin/sh
# chkconfig: 2345 80 90
# description: Start and Stop redis

PATH=/usr/local/bin:/sbin:/usr/bin:/bin
REDISPORT=6379
EXEC=/usr/local/redis/bin/redis-server
REDIS_CLI=/usr/local/redis/bin/redis-cli

PIDFILE=/var/run/redis.pid
CONF="/usr/local/redis/etc/redis.conf"
   
case "\$1" in
    start)
        if [ -f \$PIDFILE ]
        then
                echo "\$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                \$EXEC \$CONF
        fi
        if [ "\$?"="0" ] 
        then
              echo "Redis is running..."
        fi
        ;;
    stop)
        if [ ! -f \$PIDFILE ]
        then
                echo "\$PIDFILE does not exist, process is not running"
        else
                PID=\$(cat \$PIDFILE)
                echo "Stopping ..."
                \$REDIS_CLI -p \$REDISPORT SHUTDOWN
                while [ -x \${PIDFILE} ]
               do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
        fi
        ;;
   restart|force-reload)
        \${0} stop
        \${0} start
        ;;
  *)
    echo "Usage: /etc/init.d/redis {start|stop|restart|force-reload}" >&2
        exit 1
esac

EOF

chmod +x /etc/init.d/redis
chkconfig --add redis
chkconfig --level 2345 redis on

systemctl start redis

