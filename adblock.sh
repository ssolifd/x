#!/bin/bash
# Block advertisements, malware, and tracking domains using unbound recursive DNS
# Some lists are for personal use only

# Check if running as root
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@"
fi

# Copy adblocker.sh to adblock
\cp -f adblock.sh /opt/adblock.sh

# IP address to send traffic
blackHoleDNS="127.0.0.1"
blackHoleDNS6="::"

# Location of configuration file
configurationFile="/etc/unbound/local.d/adaway.conf"
rm -f $configurationFile

# Clean up for refresh
rm -f /tmp/blackhole
rm -f /tmp/blackholedomains
rm -f /tmp/blackholeuniq
rm -f /tmp/blackholeconfig
touch /tmp/blackhole

# Notice for user
echo "Please wait while we gather and install blocking lists..."

curl -s http://pgl.yoyo.org/adservers/serverlist.php? | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)' >> /tmp/blackhole
# Retrieve lists
curl -s http://www.malwaredomainlist.com/hostslist/hosts.txt | grep -v "#" | awk '{print $2}' >> /tmp/blackhole
curl -s http://winhelp2002.mvps.org/hosts.txt | grep -v "#" | awk '{print $2}' | less >> /tmp/blackhole
#curl -s http://someonewhocares.org/hosts/hosts | grep -v "#" | awk '{print $2}' >> /tmp/blackhole
curl -s https://hosts-file.net/ad_servers.txt | grep -v "#" | awk '{print $2}' >> /tmp/blackhole
curl -s https://adaway.org/hosts.txt | grep -v "#" | awk '{print $2}' >> /tmp/blackhole
curl -s http://malwaredomains.lehigh.edu/files/justdomains >> /tmp/blackhole
curl -s https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt | grep -v "#" >> /tmp/blackhole
curl -s https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt | grep -v "#" >> /tmp/blackhole
curl -s https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt | grep -v "#" >> /tmp/blackhole
#curl -s https://s3.amazonaws.com/lists.disconnect.me/simple_malware.txt | grep -v "#" >> /tmp/blackhole
curl -s https://raw.githubusercontent.com/ssolifd/1/master/hosts | grep -v "#" >> /tmp/blackhole
# Sanatize output to only domains in /tmp/blackholedomains
cat /tmp/blackhole | uniq -u > /tmp/blackholeuniq
cat /tmp/blackholeuniq | grep -v "localhost" | grep -v "local" | grep -v "127.0.0.1" | grep -v "::1" > /tmp/blackholedomains
sed -i 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' /tmp/blackholedomains

# Trim and format domains for unbound 
rm -f $configurationFile
for a in `cat /tmp/blackholedomains`; do
                echo 'local-data: "'$a' A '$blackHoleDNS'"' >> /tmp/blackholeconfig
done

for a in `cat /tmp/blackholedomains`; do
                echo 'local-data: "'$a' AAAA '$blackHoleDNS6'"' >> /tmp/blackholeconfig
done

# Remove carraige return and output configuration file
tr -d '\r' < /tmp/blackholeconfig > $configurationFile

rm -rf /tmp/blackholeconfig
curl -s https://raw.githubusercontent.com/ssolifd/x/master/ad > /tmp/blackhole
sed -i /#/d  /tmp/blackhole
cat /tmp/blackhole | uniq -u > /tmp/blackholeuniq
cat /tmp/blackholeuniq | grep -v "localhost" | grep -v "local" | grep -v "127.0.0.1" | grep -v "::1" > /tmp/blackholedomains
sed -i 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' /tmp/blackholedomains

# Trim and format domains for unbound 

for a in `cat /tmp/blackholedomains`; do
                echo 'local-zone: "'$a'"  redirect' >> /tmp/blackholeconfig
done
for a in `cat /tmp/blackholedomains`; do
                echo 'local-data: "'$a' 86400 IN A 127.0.0.1"  ' >> /tmp/blackholeconfig
done
for a in `cat /tmp/blackholedomains`; do
sed -i /$a/d /etc/unbound/local.d/adaway.conf
done

# Remove carraige return and output configuration file
tr -d '\r' < /tmp/blackholeconfig > /tmp/test

cat /tmp/test >>/etc/unbound/local.d/adaway.conf
# Cleanup
rm -f /tmp/blackhole
rm -f /tmp/blackholeuniq
rm -f /tmp/blackholeconfig

# Confirm completion
echo "Installed blocklist and set to update daily"
