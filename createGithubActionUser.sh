#!/bin/bash

username="githubactions"

# Check if the user already exists
if id "$username" >/dev/null 2>&1; then
echo "User $username already exists. Exiting."
exit 1
else

# Generate a random password
password=$(openssl rand -base64 32)

# Create the user with the generated password
sudo useradd -m -p "$(openssl passwd -1 "$password")" -s /bin/bash "$username"

# Add the user to the sudoers group with no password prompt
echo "$username ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$username

# Set correct permissions for the sudoers file
sudo chmod 0440 /etc/sudoers.d/$username

# Save password to file
echo "$password" > /root/.githubactions

echo "User $username has been created with the following password: $password"
echo "Password saved at: cat /root/.githubactions"

exit 0
fi
