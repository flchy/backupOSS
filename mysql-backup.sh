#!/bin/bash

## 备份信息 ##


# 备份名称，用于标记
BACKUP_NAME="oss"
# 备份目录，多个请空格分隔
BACKUP_SRC="/home/backups/file/"
# Mysql 主机地址
MYSQL_SERVER="localhost"
# Mysql 用户名
MYSQL_USER="root"
# Mysql 密码
MYSQL_PASS="root"
# Mysql 备份数据库，多个请空格分隔
MYSQL_DBS="db_config db_flchy"
# 备份文件临时存放目录，一般不需要更改
BACKUP_DIR="/tmp/backup-to-oss"
# 要保留的备份天数 #
backup_day=10
## 备份配置信息 End ##


## 备份配置信息 End ##

## 阿里云 OSS 配置信息 ##

# 存放空间
OSS_BUCKET="flchy"
# ACCESS_KEY
OSS_ACCESS_KEY=""
# SECRET_KEY
OSS_SECRET_KEY=""
# Endpoint 示例：https://oss-cn-shenzhen.aliyuncs.com
OSS_ENDPOINT=""

## 阿里云 OSS 配置信息 End ##



## Start ##
time="$(date +"%Y-%m-%d")"
mkdir -p $BACKUP_DIR

# 备份Mysql
echo "start dump mysql"
for db_name in $MYSQL_DBS
do
	mysqldump -u $MYSQL_USER -h $MYSQL_SERVER -p$MYSQL_PASS $db_name > "$BACKUP_DIR/$BACKUP_NAME-$db_name.sql"
tar czPvf $BACKUP_SRC$BACKUP_NAME-$db_name-$time.tar.gz $BACKUP_DIR/$BACKUP_NAME-$db_name.sql

# 上传
echo "start upload"
python $(dirname $0)/upload.py -a $OSS_ACCESS_KEY -s $OSS_SECRET_KEY -b $OSS_BUCKET -e $OSS_ENDPOINT -f $BACKUP_SRC$BACKUP_NAME-$db_name-$time.tar.gz
echo "upload ok"

done
echo "dump ok"


# 删除旧的备份
find $BACKUP_SRC -type f -mtime +${backup_day} | tee delete_list.log | xargs rm -rf


# 清理备份文件
rm -rf $BACKUP_DIR

echo "backup clean done"
