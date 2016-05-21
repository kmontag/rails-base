#!/bin/bash -e

echo
echo "APPLICATION SETUP"
echo

echo "Installing security updates..."
unattended-upgrade # Install security updates

echo "Installing AWS CLI"
apt-get install -y awscli

# Allow SSH access from the Deployers group.
# Adapted from https://cloudonaut.io/manage-aws-ec2-ssh-access-with-iam/
echo "Setting up scripts for SSH config..."
/usr/sbin/adduser deploy
echo "deploy ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/deploy

(
cat <<'AUTHORIZED_KEYS_COMMAND'
#!/bin/bash -e
if [ -z "$1" ]; then
  exit 1
fi

# Prints the active public keys for all users in the deployers group
aws iam get-group --group-name deployers --query "Users[].UserName" --output text | while read User; do

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
echo "gem: --no-ri --no-rdoc" > ~deploy/.gemrc
sudo -u deploy -H sh -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
sudo -u deploy -H sh -c "\\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3.0"
sudo -u deploy -H sh -c "~/.rvm/bin/rvm default do gem install bundler"

echo "Installing other dependencies..."

# For postgres
apt-get install -y postgresql-client libpq-dev

echo "Setting up application directory..."
mkdir -p /var/www
chown deploy:deploy /var/www
