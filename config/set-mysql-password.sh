echo "Setting MySQL password..."
echo "Whoami: " && whoami

# Remove mysql.sock.lock file
rm -rf /var/lib/mysql/mysql.sock.lock

# Creates folders necessary for mysqld
mkdir /var/run/mysqld

chown -R johndoe /var/lib/mysql
chown -R johndoe /var/run/mysqld

# Run mysqld with root user and create 'johndoe' user width md5 password 'johndoe'
# Grant all privileges
/usr/sbin/mysqld &
sleep 10
echo "CREATE USER 'johndoe'@'%' IDENTIFIED BY '6579e96f76baa00787a28653876c6127'; GRANT ALL PRIVILEGES ON *.* TO 'johndoe'@'%' IDENTIFIED BY '6579e96f76baa00787a28653876c6127'; GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql