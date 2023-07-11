#!/bin/bash

username="githubactions"

# Check if the user already exists
if id "$username" >/dev/null 2>&1; then
  # ask for a new password
  echo "User $username already exists. Do yo want to update password?"
  read -p "Type 'yes' to update password: " answer
  if [ "$answer" == "yes" ]; then
    # Generate a random password
    password=$(openssl rand -base64 32)

    # Update the user with the generated password
    sudo usermod -p "$(openssl passwd -1 "$password")" "$username"

    # Save password to file
    echo "$password" > /root/.githubactions

    echo "Password for user $username has been updated with the following password: $password"
    echo "Password saved at: cat /root/.githubactions"

    exit 0
  else
    echo "Password for user $username has not been updated. Cancelled."
    exit 0
  fi
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
