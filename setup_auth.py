"""
Script to generate secure password hashes for config.yaml
Run this script to generate a new password hash for your users.
"""
import streamlit_authenticator as stauth
import yaml
from yaml.loader import SafeLoader

# Generate password hash
# Replace 'your_password_here' with your desired password
password = input("Enter password to hash: ")
hashed_password = stauth.Hasher([password]).generate()[0]
print(f"\nHashed password: {hashed_password}")
print("\nCopy this hash to your config.yaml file under the password field.")

