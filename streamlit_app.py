import streamlit as st
import math
import yaml
from yaml.loader import SafeLoader
import streamlit_authenticator as stauth

# Page configuration for mobile responsiveness
st.set_page_config(
    page_title="RentCal - Vehicle Financing Calculator",
    page_icon="🚗",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Load configuration - support both local and Streamlit Cloud
if 'credentials' in st.secrets:
    # Running on Streamlit Cloud - use secrets
    # Validate required secrets exist
    if 'cookie' not in st.secrets:
        st.error("Missing 'cookie' configuration in Streamlit secrets. Please add cookie settings.")
        st.stop()
    
    # Convert secrets to regular dict (secrets are read-only and cannot be modified)
    # The authenticator library needs to modify the credentials dict
    config = {
        'credentials': {
            'usernames': {}
        },
        'cookie': {
            'name': st.secrets['cookie'].get('name', 'rentcal_cookie'),
            'key': st.secrets['cookie'].get('key', ''),
            'expiry_days': st.secrets['cookie'].get('expiry_days', 30)
        },
        'preauthorized': {}
    }
    
    # Copy credentials from secrets to mutable dict
    if 'usernames' not in st.secrets['credentials']:
        st.error("Missing 'usernames' in credentials. Please check your Streamlit secrets configuration.")
        st.stop()
    
    for username, user_data in st.secrets['credentials']['usernames'].items():
        config['credentials']['usernames'][username] = {
            'email': user_data.get('email', ''),
            'failed_login_attempts': user_data.get('failed_login_attempts', 0),
            'logged_in': user_data.get('logged_in', False),
            'name': user_data.get('name', username),
            'password': user_data.get('password', '')
        }
    
    # Copy preauthorized emails if they exist
    if 'preauthorized' in st.secrets and 'emails' in st.secrets['preauthorized']:
        config['preauthorized'] = {
            'emails': list(st.secrets['preauthorized']['emails'])
        }
    
    # Validate required cookie key
    if not config['cookie']['key']:
        st.error("Missing 'cookie.key' in Streamlit secrets. Please add a cookie key for security.")
        st.stop()
else:
    # Running locally - use config.yaml
    try:
        with open('config.yaml') as file:
            config = yaml.load(file, Loader=SafeLoader)
    except FileNotFoundError:
        st.error("Configuration file not found. Please ensure config.yaml exists.")
        st.stop()

# Initialize authenticator
# Note: preauthorized parameter has been removed in newer versions
authenticator = stauth.Authenticate(
    config['credentials'],
    config['cookie']['name'],
    config['cookie']['key'],
    config['cookie']['expiry_days']
)

# Authentication
name, authentication_status, username = authenticator.login('Login', 'main')

if authentication_status == False:
    st.error('Username/password is incorrect')
    st.stop()
elif authentication_status == None:
    st.warning('Please enter your username and password')
    st.stop()
elif authentication_status:
    # Logout button in sidebar
    with st.sidebar:
        st.write(f'Welcome *{name}*')
        authenticator.logout('Logout', 'sidebar')

# Custom CSS for mobile responsiveness
st.markdown("""
    <style>
        /* Mobile-first responsive design */
        @media (max-width: 768px) {
            .main .block-container {
                padding: 1rem;
            }
            h1 {
                font-size: 1.75rem !important;
            }
            .stNumberInput > div > div > input {
                font-size: 16px !important; /* Prevents zoom on iOS */
            }
        }
        
        /* Center align title */
        h1 {
            text-align: center;
            color: #6200EE;
            margin-bottom: 2rem;
        }
        
        /* Result box styling */
        .result-box {
            background-color: #F5F5F5;
            border: 2px solid #BB86FC;
            border-radius: 8px;
            padding: 1.5rem;
            margin-top: 1.5rem;
            text-align: center;
        }
        
        .result-label {
            font-size: 1.2rem;
            font-weight: bold;
            color: #3700B3;
            margin-bottom: 0.5rem;
        }
        
        .result-value {
            font-size: 2.5rem;
            font-weight: bold;
            color: #3700B3;
        }
        
        /* Button styling */
        .stButton > button {
            width: 100%;
            background-color: #6200EE;
            color: white;
            font-size: 1.1rem;
            padding: 0.75rem;
            border-radius: 8px;
            border: none;
        }
        
        .stButton > button:hover {
            background-color: #3700B3;
        }
        
        /* Input field styling */
        .stNumberInput label {
            font-weight: 600;
            color: #6200EE;
        }
        
        /* Divider styling */
        .divider {
            text-align: center;
            margin: 1.5rem 0;
            font-weight: bold;
            color: #6200EE;
        }
    </style>
""", unsafe_allow_html=True)

def calculate_emi(principal: float, annual_interest_rate: float, total_months: int) -> float:
    """
    Calculate EMI (Equated Monthly Installment) using the standard formula:
    EMI = P * [r * (1 + r)^n] / [(1 + r)^n - 1]
    
    Where:
    P = Principal amount (Facility Amount)
    r = Monthly interest rate (Annual Interest Rate / 12 / 100)
    n = Total number of months
    """
    if annual_interest_rate == 0.0:
        return principal / total_months
    
    monthly_interest_rate = annual_interest_rate / 12.0 / 100.0
    one_plus_r_to_n = math.pow(1 + monthly_interest_rate, total_months)
    emi = principal * (monthly_interest_rate * one_plus_r_to_n) / (one_plus_r_to_n - 1)
    
    return emi

def calculate_repayment_period(principal: float, annual_interest_rate: float, monthly_installment: float) -> int:
    """
    Calculate Repayment Period (in months) from EMI using reverse formula:
    n = ln(EMI / (EMI - P * r)) / ln(1 + r)
    
    Where:
    P = Principal amount (Facility Amount)
    r = Monthly interest rate (Annual Interest Rate / 12 / 100)
    EMI = Monthly Installment
    n = Total number of months
    """
    if annual_interest_rate == 0.0:
        return int(principal / monthly_installment)
    
    monthly_interest_rate = annual_interest_rate / 12.0 / 100.0
    denominator = monthly_installment - (principal * monthly_interest_rate)
    
    if denominator <= 0:
        return -1
    
    numerator = monthly_installment / denominator
    total_months = math.log(numerator) / math.log(1 + monthly_interest_rate)
    
    return int(total_months)

def format_currency(value: float) -> str:
    """Format number as currency with thousand separators"""
    return f"{value:,.2f}"

def format_repayment_period(total_months: int) -> str:
    """Format repayment period as Years and Months"""
    years = total_months // 12
    months = total_months % 12
    
    if years > 0 and months > 0:
        return f"{years} Years {months} Months"
    elif years > 0:
        return f"{years} Years"
    else:
        return f"{months} Months"

# Main App
st.title("🚗 RentCal - Vehicle Financing Calculator")

# Create two columns for better layout on desktop, stack on mobile
col1, col2 = st.columns([1, 1])

with col1:
    st.subheader("📊 Input Parameters")
    
    # Facility Amount
    facility_amount = st.number_input(
        "Facility Amount / Capital",
        min_value=0.0,
        value=100000.0,
        step=1000.0,
        format="%.2f",
        help="Enter the total amount you would like to lease"
    )
    
    # Annual Interest Rate
    annual_interest_rate = st.number_input(
        "Annual Interest Rate (%)",
        min_value=0.0,
        value=12.0,
        step=0.1,
        format="%.2f",
        help="Enter the annual interest rate"
    )

with col2:
    st.subheader("🔢 Calculation Mode")
    
    # Calculation mode selection
    calculation_mode = st.radio(
        "Select calculation mode:",
        ["Calculate Monthly Installment", "Calculate Repayment Period"],
        help="Choose what you want to calculate"
    )

# Divider
st.markdown('<div class="divider">━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</div>', unsafe_allow_html=True)

# Conditional inputs based on calculation mode
if calculation_mode == "Calculate Monthly Installment":
    st.subheader("📅 Repayment Period")
    
    col_years, col_months = st.columns(2)
    
    with col_years:
        years = st.number_input(
            "Years",
            min_value=0,
            value=5,
            step=1,
            help="Enter number of years"
        )
    
    with col_months:
        months = st.number_input(
            "Months",
            min_value=0,
            max_value=11,
            value=0,
            step=1,
            help="Enter number of months (0-11)"
        )
    
    # Calculate button
    if st.button("Calculate Monthly Installment", type="primary", use_container_width=True):
        if facility_amount <= 0:
            st.error("Facility amount must be greater than 0")
        elif annual_interest_rate < 0:
            st.error("Interest rate cannot be negative")
        elif years < 0 or months < 0:
            st.error("Repayment period cannot be negative")
        elif years == 0 and months == 0:
            st.error("Repayment period must be greater than 0")
        else:
            total_months = (years * 12) + months
            monthly_installment = calculate_emi(facility_amount, annual_interest_rate, total_months)
            
            # Display result
            st.markdown(f"""
                <div class="result-box">
                    <div class="result-label">Monthly Installment</div>
                    <div class="result-value">{format_currency(monthly_installment)}</div>
                </div>
            """, unsafe_allow_html=True)
            
            # Additional information
            with st.expander("📋 Calculation Details"):
                st.write(f"**Facility Amount:** {format_currency(facility_amount)}")
                st.write(f"**Repayment Period:** {format_repayment_period(total_months)} ({total_months} months)")
                st.write(f"**Annual Interest Rate:** {annual_interest_rate}%")
                st.write(f"**Monthly Interest Rate:** {annual_interest_rate / 12:.4f}%")
                st.write(f"**Total Interest:** {format_currency((monthly_installment * total_months) - facility_amount)}")
                st.write(f"**Total Amount:** {format_currency(monthly_installment * total_months)}")

else:  # Calculate Repayment Period
    st.subheader("💰 Monthly Installment")
    
    monthly_installment = st.number_input(
        "Monthly Installment Amount",
        min_value=0.0,
        value=2224.44,
        step=100.0,
        format="%.2f",
        help="Enter the desired monthly installment amount"
    )
    
    # Calculate button
    if st.button("Calculate Repayment Period", type="primary", use_container_width=True):
        if facility_amount <= 0:
            st.error("Facility amount must be greater than 0")
        elif annual_interest_rate < 0:
            st.error("Interest rate cannot be negative")
        elif monthly_installment <= 0:
            st.error("Monthly installment must be greater than 0")
        else:
            monthly_interest_min = facility_amount * annual_interest_rate / 12.0 / 100.0
            if monthly_installment < monthly_interest_min:
                st.error(f"Monthly installment is too low. It must be at least {format_currency(monthly_interest_min)} to cover the interest.")
            else:
                total_months = calculate_repayment_period(facility_amount, annual_interest_rate, monthly_installment)
                
                if total_months <= 0:
                    st.error("Invalid calculation. Please check your inputs.")
                else:
                    repayment_period = format_repayment_period(total_months)
                    
                    # Display result
                    st.markdown(f"""
                        <div class="result-box">
                            <div class="result-label">Repayment Period</div>
                            <div class="result-value">{repayment_period}</div>
                        </div>
                    """, unsafe_allow_html=True)
                    
                    # Additional information
                    with st.expander("📋 Calculation Details"):
                        st.write(f"**Facility Amount:** {format_currency(facility_amount)}")
                        st.write(f"**Monthly Installment:** {format_currency(monthly_installment)}")
                        st.write(f"**Annual Interest Rate:** {annual_interest_rate}%")
                        st.write(f"**Monthly Interest Rate:** {annual_interest_rate / 12:.4f}%")
                        st.write(f"**Total Number of Months:** {total_months}")
                        st.write(f"**Total Interest:** {format_currency((monthly_installment * total_months) - facility_amount)}")
                        st.write(f"**Total Amount:** {format_currency(monthly_installment * total_months)}")

# Footer
st.markdown("---")
st.markdown(
    "<div style='text-align: center; color: #666; padding: 1rem;'>"
    "Built with ❤️ using Streamlit | Vehicle Financing Installment Calculator"
    "</div>",
    unsafe_allow_html=True
)
