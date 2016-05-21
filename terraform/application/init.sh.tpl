#!/bin/bash -e

echo
echo "APPLICATION SETUP"
echo

echo "Installing security updates..."
apt-get update
unattended-upgrade # Install security updates

echo "Installing AWS CLI"
apt-get install -y awscli

# Allow SSH access from the deployers group.
# Adapted from https://cloudonaut.io/manage-aws-ec2-ssh-access-with-iam/
echo "Setting up scripts for SSH config..."
/usr/sbin/adduser ${username}
echo "${username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${username}

(
cat <<'AUTHORIZED_KEYS_COMMAND'
#!/bin/bash -e
if [ -z "$1" ]; then
  exit 1
fi

# Prints the active public keys for all users in the deployers group
aws iam get-group --group-name ${deploy_group_name} --query "Users[].UserName" --output text | while read User; do

  aws iam list-ssh-public-keys --user-name "$User" --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" --output text | while read KeyId; do
    aws iam get-ssh-public-key --user-name "$User" --ssh-public-key-id "$KeyId" --encoding SSH --query "SSHPublicKey.SSHPublicKeyBody" --output text | sed "s/\$/ $User/"
  done
done
AUTHORIZED_KEYS_COMMAND
) > /opt/authorized_keys_command.sh
chmod +x /opt/authorized_keys_command.sh

echo "Enabling SSH access..."
echo "AuthorizedKeysCommand /opt/authorized_keys_command.sh" >> /etc/ssh/sshd_config
echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config
service ssh restart

echo "Installing Ruby..."
sudo -u ${username} -H sh -c "echo \"gem: --no-ri --no-rdoc\" > ~/.gemrc"
sudo -u ${username} -H sh -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
sudo -u ${username} -H sh -c "\\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3.0"
sudo -u ${username} -H sh -c "~/.rvm/bin/rvm default do gem install bundler"

echo "Installing other dependencies..."

# nginx
apt-get install -y nginx
rm /etc/nginx/sites-enabled/default
service nginx restart

# Postgres
apt-get install -y postgresql-client libpq-dev

# Node
curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-get install -y nodejs

echo "Setting up application directory..."
mkdir -p /var/www/${application_name}
chown ${username}:${username} /var/www/${application_name}

# Note db_password can't have double-quotes, so this interpolation is safe
(
cat <<DOTENV
DATABASE_USERNAME="${db_username}"
DATABASE_PASSWORD="${db_password}"
DATABASE_HOST="${db_host}"
DOTENV
) > /tmp/env.production
sudo -u ${username} -H sh -c "mkdir -p /var/www/${application_name}/shared"
sudo -u ${username} -H sh -c "cp /tmp/env.production /var/www/${application_name}/shared/.env.production"
