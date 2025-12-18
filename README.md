# RentCal - Vehicle Financing Installment Calculator

An Android mobile application for calculating vehicle financing monthly installments.

## Features

- Calculate monthly installments based on:
  - Facility Amount / Capital
  - Repayment Period (Years and Months)
  - Annual Interest Rate

## Calculation Formula

The app uses the standard EMI (Equated Monthly Installment) formula:

```
EMI = P × [r × (1 + r)^n] / [(1 + r)^n - 1]
```

Where:
- P = Principal amount (Facility Amount)
- r = Monthly interest rate (Annual Interest Rate / 12 / 100)
- n = Total number of months (Years × 12 + Months)

## Example

- Facility Amount: 100,000
- Repayment Period: 5 Years, 0 Months
- Annual Interest Rate: 12%
- Monthly Installment: 2,202.42

## Requirements

- Android Studio Hedgehog or later
- Minimum SDK: 24 (Android 7.0)
- Target SDK: 34 (Android 14)
- Kotlin

## Building the App

1. Open the project in Android Studio
2. Sync Gradle files
3. Build and run the app on an emulator or physical device

## Usage

1. Enter the Facility Amount
2. Enter the Repayment Period (Years and Months)
3. Enter the Annual Interest Rate (%)
4. Tap the "Calculate" button
5. View the calculated Monthly Installment

