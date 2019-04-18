wget http://update.aegis.aliyun.com/download/uninstall.sh
chmod +x uninstall.sh
sudo ./uninstall.sh
wget http://update.aegis.aliyun.com/download/quartz_uninstall.sh
chmod +x quartz_uninstall.sh
sudo ./quartz_uninstall.sh
sudo pkill aliyun-service
sudo rm -rf /etc/init.d/agentwatch /usr/sbin/aliyun-service
sudo rm -rf /usr/sbin/aliyun*
sudo rm -rf /etc/systemd/system/aliyun.service
sudo rm -rf /usr/local/aegis*
/usr/local/cloudmonitor/CmsGoAgent.linux-amd64 stop && \
/usr/local/cloudmonitor/CmsGoAgent.linux-amd64 uninstall && \
rm -rf /usr/local/cloudmonitor
/usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh stop
/usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh remove && \
rm -rf /usr/local/cloudmonitor
