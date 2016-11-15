#!/bin/bash


##############
# Install deps
##############
# Ubuntu
apt-get update -y 
apt-get upgrade -y 
apt-get install python-pip jq -y
#####################

# Amazon Linux (RHEL) - NAT instances
yum update
curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python2.7

#####################

pip install awscli

apt-get install ntp

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

cat <<"EOF" > /etc/ntp.conf
driftfile /var/lib/ntp/ntp.drift
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
server 0.ubuntu.pool.ntp.org
server 1.ubuntu.pool.ntp.org
server 2.ubuntu.pool.ntp.org
server 3.ubuntu.pool.ntp.org
server ntp.ubuntu.com
restrict -4 ignore
restrict -6 ignore
restrict 10.40.0.0 mask 255.255.0.0
restrict 10.50.0.0 mask 255.255.0.0
restrict distilnode-1.endservices.info
restrict distilnode-0.endservices.info
restrict 127.0.0.1
restrict ::1
EOF

service ntp restart



##############

cat <<"EOF" > /home/ubuntu/update_ssh_authorized_keys.sh
#!/usr/bin/env bash
set -e
BUCKET_NAME=${s3_bucket_name}
BUCKET_URI=${s3_bucket_uri}
SSH_USER=${ssh_user}
MARKER="# KEYS_BELOW_WILL_BE_UPDATED_BY_TERRAFORM"
KEYS_FILE=/home/$SSH_USER/.ssh/authorized_keys
TEMP_KEYS_FILE=$(mktemp /tmp/authorized_keys.XXXXXX)
PUB_KEYS_DIR=/home/$SSH_USER/pub_key_files/
[[ -z $BUCKET_URI ]] && BUCKET_URI="s3://$BUCKET_NAME/"
mkdir -p $PUB_KEYS_DIR
# Add marker, if not present, and copy static content.
grep -Fxq "$MARKER" $KEYS_FILE || echo -e "\n$MARKER" >> $KEYS_FILE
line=$(grep -n "$MARKER" $KEYS_FILE | cut -d ":" -f 1)
head -n $line $KEYS_FILE > $TEMP_KEYS_FILE
# Synchronize the keys from the bucket.
aws s3 sync --delete $BUCKET_URI $PUB_KEYS_DIR
for filename in $PUB_KEYS_DIR/*; do
    sed 's/\n\?$/\n/' < $filename >> $TEMP_KEYS_FILE
done
# Move the new authorized keys in place.
chown $SSH_USER:$SSH_USER $KEYS_FILE
chmod 600 $KEYS_FILE
mv $TEMP_KEYS_FILE $KEYS_FILE
EOF

chown ${ssh_user}:${ssh_user} /home/${ssh_user}/update_ssh_authorized_keys.sh
chmod 755 /home/${ssh_user}/update_ssh_authorized_keys.sh

# Execute now
su ${ssh_user} -c /home/${ssh_user}/update_ssh_authorized_keys.sh

# Be backwards compatible with old cron update enabler
if [ "${enable_hourly_cron_updates}" = 'true' -a -z "${keys_update_frequency}" ]; then
  keys_update_frequency="0 * * * *"
else
  keys_update_frequency="${keys_update_frequency}"
fi

# Add to cron
if [ -n "$keys_update_frequency" ]; then
  croncmd="/home/${ssh_user}/update_ssh_authorized_keys.sh"
  cronjob="$keys_update_frequency $croncmd"
  ( crontab -u ${ssh_user} -l | grep -v "$croncmd" ; echo "$cronjob" ) | crontab -u ${ssh_user} -
fi

# Append addition user-data script
${additional_user_data_script}
# This script will update motd and list available instances to login
# Script is far from perfect, so please consider improving it and send pull-request.

cat <<"INSTANCES_SCRIPT" > /etc/update-motd.d/60-update-list-of-running-instances
#!/bin/bash
aws configure set region eu-west-1
echo ""
echo ""
echo "Current instances grouped by AutoScaling Groups:"
# get all ASG
for asg in `aws autoscaling describe-auto-scaling-groups --output text  --query 'AutoScalingGroups[*].AutoScalingGroupName'`; do
echo ""
echo "Autoscaling group name: $asg"
# get all instances in ASG
for ip in `aws ec2 describe-instances --filters Name=tag-key,Values='aws:autoscaling:groupName' Name=tag-value,Values=$asg --output text --query 'Reservations[*].Instances[*].[PrivateIpAddress]'`; do
  echo $ip
done
echo ""
echo "========================================================================="
done
echo ""
echo "Log on to the boxes with: ssh <IP address>"
echo ""
INSTANCES_SCRIPT

chmod +x /etc/update-motd.d/60-update-list-of-running-instances

