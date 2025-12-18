# Deployment Guide for RentCal Streamlit App

This guide will help you deploy the RentCal application to Streamlit Cloud with user authentication.

## Prerequisites

1. A GitHub account
2. A Streamlit Cloud account (free at https://streamlit.io/cloud)
3. Git installed on your local machine

## Step 1: Prepare Your Repository

1. Initialize a Git repository (if not already done):
```bash
git init
git add .
git commit -m "Initial commit: RentCal Streamlit app with authentication"
```

2. Create a GitHub repository and push your code:
```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

## Step 2: Set Up Authentication

### Option A: Generate Secure Password Hashes

1. Install dependencies locally:
```bash
pip install streamlit-authenticator bcrypt pyyaml
```

2. Run the password hash generator:
```bash
python setup_auth.py
```

3. Enter your desired password when prompted
4. Copy the generated hash
5. Update `config.yaml` with your hashed password

### Option B: Use Default Password (NOT RECOMMENDED FOR PRODUCTION)

The default password in `config.yaml.example` is `admin123`. For production, you MUST change this!

## Step 3: Configure Streamlit Cloud Secrets

1. Go to https://share.streamlit.io/
2. Sign in with your GitHub account
3. Click "New app"
4. Connect your GitHub repository
5. Set the main file path to: `streamlit_app.py`
6. Click "Advanced settings"

### Add Secrets

In the "Secrets" section, add your `config.yaml` content. Streamlit Cloud uses a TOML format for secrets, but you can also use YAML.

**Option 1: Using TOML format in Streamlit Secrets**

Go to "Secrets" and add:

```toml
[credentials.usernames.admin]
email = "admin@rentcal.com"
failed_login_attempts = 0
logged_in = false
name = "Administrator"
password = "YOUR_HASHED_PASSWORD_HERE"

[credentials.usernames.user]
email = "user@rentcal.com"
failed_login_attempts = 0
logged_in = false
name = "User"
password = "YOUR_HASHED_PASSWORD_HERE"

[cookie]
expiry_days = 30
key = "YOUR_RANDOM_COOKIE_KEY_HERE"
name = "rentcal_cookie"

[preauthorized]
emails = ["admin@rentcal.com"]
```

**Option 2: Using YAML file (Recommended)**

1. Create a `.streamlit/secrets.toml` file locally (but don't commit it - it's in .gitignore)
2. Or upload your `config.yaml` content directly in Streamlit Cloud's secrets manager

## Step 4: Update streamlit_app.py for Cloud Deployment

The app needs to read secrets from Streamlit's secrets manager when deployed. Update the config loading section:

```python
# Load configuration
if 'credentials' in st.secrets:
    # Running on Streamlit Cloud - use secrets
    config = {
        'credentials': st.secrets['credentials'],
        'cookie': st.secrets['cookie'],
        'preauthorized': st.secrets.get('preauthorized', {})
    }
else:
    # Running locally - use config.yaml
    try:
        with open('config.yaml') as file:
            config = yaml.load(file, Loader=SafeLoader)
    except FileNotFoundError:
        st.error("Configuration file not found. Please ensure config.yaml exists.")
        st.stop()
```

## Step 5: Deploy to Streamlit Cloud

1. In Streamlit Cloud, click "Deploy"
2. Wait for the deployment to complete
3. Your app will be available at: `https://YOUR_APP_NAME.streamlit.app`

## Step 6: Access Your App

1. Visit your deployed app URL
2. Login with your credentials:
   - Username: `admin` or `user`
   - Password: (the password you set in Step 2)

## Security Best Practices

1. **Change Default Passwords**: Never use default passwords in production
2. **Use Strong Passwords**: Generate strong, unique passwords
3. **Rotate Cookie Keys**: Change the cookie key in your secrets
4. **Limit Users**: Remove unnecessary user accounts
5. **Use HTTPS**: Streamlit Cloud automatically provides HTTPS
6. **Regular Updates**: Keep dependencies updated

## Troubleshooting

### Authentication Not Working

- Verify your secrets are correctly formatted in Streamlit Cloud
- Check that password hashes are correct
- Ensure cookie key is set properly

### App Not Loading

- Check that `streamlit_app.py` is in the root directory
- Verify all dependencies are in `requirements.txt`
- Check Streamlit Cloud logs for errors

### Local Testing

To test locally before deploying:

1. Ensure `config.yaml` exists with your credentials
2. Run: `streamlit run streamlit_app.py`
3. Test login functionality

## Alternative: Using Environment Variables

You can also use environment variables for sensitive data:

1. In Streamlit Cloud, go to "Settings" > "Secrets"
2. Add environment variables
3. Update your code to read from `os.environ`

## Support

For issues with:
- **Streamlit Cloud**: Check https://docs.streamlit.io/streamlit-community-cloud
- **Authentication**: Check streamlit-authenticator documentation
- **App Issues**: Review the app logs in Streamlit Cloud dashboard

