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
aws iam get-group --group-name ${deployers_iam_group_name} --query "Users[].UserName" --output text | while read User; do
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

# https://forums.aws.amazon.com/message.jspa?messageID=495274
echo "127.0.0.1 $(hostname)" >> /etc/hosts

echo "Copying deploy key..."
mkdir -p /home/deploy/.ssh
chown ${username}:${username} /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
(
cat <<'DEPLOY_KEY'
${deploy_key}
DEPLOY_KEY
) > /home/${username}/.ssh/id_rsa
chown ${username}:${username} /home/${username}/.ssh/id_rsa
chmod 600 /home/${username}/.ssh/id_rsa

echo "Installing Ruby..."
sudo -u ${username} -H sh -c "echo \"gem: --no-ri --no-rdoc\" > ~/.gemrc"
sudo -u ${username} -H sh -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"

sudo -u ${username} -H sh -c "\\curl -sSL https://raw.githubusercontent.com/wayneeseguin/rvm/stable/binscripts/rvm-installer | bash -s stable --ruby=${ruby_version}"
# sudo -u ${username} -H sh -c "\\curl -sSL https://get.rvm.io | bash -s stable --ruby=${ruby_version}" # Pending https://github.com/rvm/rvm/issues/4068
sudo -u ${username} -H sh -c "~/.rvm/bin/rvm default do gem install bundler --version=${bundler_version}"

echo "Installing nginx..."

apt-get install -y nginx
rm /etc/nginx/sites-enabled/default
service nginx restart

echo "Installing postgres client..."
apt-get install -y postgresql-client libpq-dev

echo "Installing Node..."
curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-get install -y nodejs
npm install -g npm@${npm_version}

echo "Setting up application directory..."
mkdir -p /var/www/${application_name}
chown ${username}:${username} /var/www/${application_name}

# Note db_password can't have double-quotes, so this interpolation is safe
(
cat <<DOTENV
DATABASE_NAME="${database_name}"
DATABASE_USERNAME="${database_username}"
DATABASE_PASSWORD="${database_password}"
DATABASE_HOST="${database_host}"
DOTENV
) > /tmp/env.production
sudo -u ${username} -H sh -c "mkdir -p /var/www/${application_name}/shared"
sudo -u ${username} -H sh -c "cp /tmp/env.production /var/www/${application_name}/shared/.env.production"

echo "Running pre-deploy setup..."
# Pre-populate github/bitbucket host keys
(
cat <<'KNOWN_HOSTS'
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==
KNOWN_HOSTS
) > /home/${username}/.ssh/known_hosts
chown ${username}:${username} /home/${username}/.ssh/known_hosts
chmod 644 /home/${username}/.ssh/known_hosts

# The Capistrano puma plugin needs to run some additional setup
sudo -u ${username} -H sh -c "git clone ${repo_url} /tmp/deploy"
sudo -u ${username} -H sh -c "cd /tmp/deploy && ~/.rvm/bin/rvm default do bundle install --gemfile=Gemfile.deploy"
sudo -u ${username} -H sh -c "cd /tmp/deploy && CAPISTRANO_DEPLOY_LOCALLY=1 BUNDLE_GEMFILE=Gemfile.deploy ~/.rvm/bin/rvm default do bundle exec cap production puma:config puma:nginx_config"
sudo -u ${username} -H sh -c "mkdir -p /var/www/${application_name}/shared/log"
service nginx restart