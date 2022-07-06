echo "Port: "
read p

firewall-cmd --permanent --zone=public --add-port=$p/tcp
firewall-cmd --permanent --zone=public --add-port=$p/udp
firewall-cmd --reload
