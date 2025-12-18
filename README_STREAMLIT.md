# RentCal - Streamlit Web Application

A mobile-responsive web application for calculating vehicle financing installments using Streamlit.

## Features

- **Forward Calculation**: Calculate Monthly Installment from Facility Amount, Repayment Period, and Interest Rate
- **Reverse Calculation**: Calculate Repayment Period from Facility Amount, Interest Rate, and Monthly Installment
- **Mobile Responsive**: Optimized for both desktop and mobile devices
- **Detailed Results**: Shows calculation details including total interest and total amount

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

## Running the Application

Run the Streamlit app using:
```bash
streamlit run streamlit_app.py
```

The application will open in your default web browser at `http://localhost:8501`

## Usage

### Forward Calculation (Monthly Installment)

1. Enter the **Facility Amount / Capital**
2. Enter the **Annual Interest Rate (%)**
3. Select **"Calculate Monthly Installment"** mode
4. Enter **Years** and **Months** for the repayment period
5. Click **"Calculate Monthly Installment"** button
6. View the calculated monthly installment and detailed breakdown

### Reverse Calculation (Repayment Period)

1. Enter the **Facility Amount / Capital**
2. Enter the **Annual Interest Rate (%)**
3. Select **"Calculate Repayment Period"** mode
4. Enter the **Monthly Installment Amount**
5. Click **"Calculate Repayment Period"** button
6. View the calculated repayment period and detailed breakdown

## Calculation Formula

### Forward Calculation (EMI)
```
EMI = P × [r × (1 + r)^n] / [(1 + r)^n - 1]
```
Where:
- P = Principal amount (Facility Amount)
- r = Monthly interest rate (Annual Interest Rate / 12 / 100)
- n = Total number of months

### Reverse Calculation (Repayment Period)
```
n = ln(EMI / (EMI - P × r)) / ln(1 + r)
```
Where:
- P = Principal amount (Facility Amount)
- r = Monthly interest rate (Annual Interest Rate / 12 / 100)
- EMI = Monthly Installment
- n = Total number of months

## Example

**Forward Calculation:**
- Facility Amount: 100,000
- Repayment Period: 5 Years, 0 Months
- Annual Interest Rate: 12%
- **Result:** Monthly Installment ≈ 2,224.44

**Reverse Calculation:**
- Facility Amount: 100,000
- Annual Interest Rate: 12%
- Monthly Installment: 2,224.44
- **Result:** Repayment Period ≈ 5 Years 0 Months

## Mobile Responsiveness

The application is optimized for mobile devices with:
- Responsive layout that adapts to screen size
- Touch-friendly input fields
- Font size adjustments for mobile readability
- Proper input field sizing to prevent iOS zoom

## Technologies Used

- **Streamlit**: Web application framework
- **Python**: Programming language
- **Math**: For financial calculations

