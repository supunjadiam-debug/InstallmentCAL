# Quick Start Guide - Deploy RentCal to Streamlit Cloud

## Step 1: Generate Secure Password

1. Install dependencies:
```bash
pip install streamlit-authenticator bcrypt pyyaml
```

2. Run the password generator:
```bash
python setup_auth.py
```

3. Enter your desired password (e.g., `MySecurePassword123!`)
4. Copy the generated hash

## Step 2: Update Configuration

1. Open `config.yaml`
2. Replace the password hashes with your generated hash
3. Change the cookie key to a random string (e.g., `my_random_cookie_key_12345`)

## Step 3: Push to GitHub

1. Create a new GitHub repository
2. Push your code:
```bash
git init
git add .
git commit -m "Initial commit: RentCal with authentication"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

## Step 4: Deploy to Streamlit Cloud

1. Go to https://share.streamlit.io/
2. Sign in with GitHub
3. Click "New app"
4. Select your repository
5. Set main file: `streamlit_app.py`
6. Click "Advanced settings"

## Step 5: Add Secrets in Streamlit Cloud

In the "Secrets" section, paste this (replace with your values):

```toml
[credentials.usernames.admin]
email = "admin@rentcal.com"
failed_login_attempts = 0
logged_in = false
name = "Administrator"
password = "YOUR_GENERATED_PASSWORD_HASH_HERE"

[credentials.usernames.user]
email = "user@rentcal.com"
failed_login_attempts = 0
logged_in = false
name = "User"
password = "YOUR_GENERATED_PASSWORD_HASH_HERE"

[cookie]
expiry_days = 30
key = "YOUR_RANDOM_COOKIE_KEY_HERE"
name = "rentcal_cookie"

[preauthorized]
emails = ["admin@rentcal.com"]
```

## Step 6: Deploy

1. Click "Deploy"
2. Wait for deployment
3. Access your app at: `https://YOUR_APP_NAME.streamlit.app`

## Step 7: Login

- Username: `admin` or `user`
- Password: The password you set in Step 1

## Default Credentials (CHANGE THESE!)

- Username: `admin`
- Password: `admin123` (in config.yaml - MUST CHANGE!)

## Troubleshooting

- **Can't login?** Check that password hash in secrets matches your password
- **App not loading?** Check Streamlit Cloud logs
- **Import errors?** Ensure all packages are in `requirements.txt`

