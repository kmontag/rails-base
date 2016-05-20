#!/bin/bash -e

echo
echo "APPLICATION SETUP"
echo

echo "Installing security updates..."
unattended-upgrades # Install security updates

echo "Installing AWS CLI"
apt-get install -y awscli

# Allow SSH access from the Deployers group.
# Adapted from https://cloudonaut.io/manage-aws-ec2-ssh-access-with-iam/
echo "Setting up scripts for SSH config..."
(
cat <<'IMPORT_USERS'
#!/bin/bash
aws iam list-users --query "Users[].[UserName]" --output text | while read User; do
  if id -u "$User" >/dev/null 2>&1; then
    echo "$User exists"
  else
    /usr/sbin/adduser "$User"
    echo "$User ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$User"
  fi
done
IMPORT_USERS
) > /opt/import_users.sh
chmod +x /opt/import_users.sh

echo "*/10 * * * * root /opt/import_users.sh" > /etc/cron.d/import_users # Check for new users every 10 minutes

(
cat <<'AUTHORIZED_KEYS_COMMAND'
#!/bin/bash -e
if [ -z "$1" ]; then
  exit 1
fi

aws iam list-ssh-public-keys --user-name "$1" --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" --output text | while read KeyId; do
  aws iam get-ssh-public-key --user-name "$1" --ssh-public-key-id "$KeyId" --encoding SSH --query "SSHPublicKey.SSHPublicKeyBody" --output text
done
AUTHORIZED_KEYS_COMMAND
) > /opt/authorized_keys_command.sh
chmod +x /opt/authorized_keys_command.sh

echo "Enabling SSH access..."
echo "AuthorizedKeysCommand /opt/authorized_keys_command.sh" >> /etc/ssh/sshd_config
echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config
service ssh restart

echo "Importing users..."
/opt/import_users.sh # Run once immediately
