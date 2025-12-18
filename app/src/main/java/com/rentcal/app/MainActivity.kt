package com.rentcal.app

import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.rentcal.app.databinding.ActivityMainBinding
import java.text.DecimalFormat
import kotlin.math.ln
import kotlin.math.pow

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnCalculate.setOnClickListener {
            calculateMonthlyInstallment()
        }
    }

    private fun calculateMonthlyInstallment() {
        // Get input values
        val facilityAmountStr = binding.etFacilityAmount.text.toString().trim()
        val yearsStr = binding.etYears.text.toString().trim()
        val monthsStr = binding.etMonths.text.toString().trim()
        val interestRateStr = binding.etInterestRate.text.toString().trim()
        val monthlyInstallmentStr = binding.etMonthlyInstallment.text.toString().trim()

        // Validate required inputs
        if (TextUtils.isEmpty(facilityAmountStr)) {
            binding.etFacilityAmount.error = getString(R.string.enter_facility_amount)
            binding.etFacilityAmount.requestFocus()
            return
        }

        if (TextUtils.isEmpty(interestRateStr)) {
            binding.etInterestRate.error = getString(R.string.enter_interest_rate)
            binding.etInterestRate.requestFocus()
            return
        }

        // Check which calculation mode: forward (Repayment Period -> Installment) or reverse (Installment -> Repayment Period)
        val hasRepaymentPeriod = !TextUtils.isEmpty(yearsStr) || !TextUtils.isEmpty(monthsStr)
        val hasMonthlyInstallment = !TextUtils.isEmpty(monthlyInstallmentStr)

        if (!hasRepaymentPeriod && !hasMonthlyInstallment) {
            Toast.makeText(this, getString(R.string.enter_repayment_period_or_installment), Toast.LENGTH_SHORT).show()
            return
        }

        if (hasRepaymentPeriod && hasMonthlyInstallment) {
            Toast.makeText(this, "Please enter either Repayment Period OR Monthly Installment, not both", Toast.LENGTH_SHORT).show()
            return
        }

        try {
            val facilityAmount = facilityAmountStr.toDouble()
            val annualInterestRate = interestRateStr.toDouble()

            // Validate positive values
            if (facilityAmount <= 0) {
                Toast.makeText(this, "Facility amount must be greater than 0", Toast.LENGTH_SHORT).show()
                return
            }

            if (annualInterestRate < 0) {
                Toast.makeText(this, "Interest rate cannot be negative", Toast.LENGTH_SHORT).show()
                return
            }

            val decimalFormat = DecimalFormat("#,##0.00")

            if (hasRepaymentPeriod) {
                // Forward calculation: Repayment Period -> Monthly Installment
                val years = if (TextUtils.isEmpty(yearsStr)) 0 else yearsStr.toInt()
                val months = if (TextUtils.isEmpty(monthsStr)) 0 else monthsStr.toInt()

                if (years < 0 || months < 0) {
                    Toast.makeText(this, "Repayment period cannot be negative", Toast.LENGTH_SHORT).show()
                    return
                }

                if (years == 0 && months == 0) {
                    Toast.makeText(this, "Repayment period must be greater than 0", Toast.LENGTH_SHORT).show()
                    return
                }

                val totalMonths = (years * 12) + months
                val monthlyInstallment = calculateEMI(facilityAmount, annualInterestRate, totalMonths)

                // Display result
                binding.tvResultLabel.text = getString(R.string.monthly_installment)
                binding.tvResultValue.text = decimalFormat.format(monthlyInstallment)
                binding.tvResultValue.textSize = 32f
                binding.resultContainer.visibility = View.VISIBLE

            } else if (hasMonthlyInstallment) {
                // Reverse calculation: Monthly Installment -> Repayment Period
                val monthlyInstallment = monthlyInstallmentStr.toDouble()

                if (monthlyInstallment <= 0) {
                    Toast.makeText(this, "Monthly installment must be greater than 0", Toast.LENGTH_SHORT).show()
                    return
                }

                if (monthlyInstallment < facilityAmount * annualInterestRate / 12.0 / 100.0) {
                    Toast.makeText(this, "Monthly installment is too low for the given interest rate", Toast.LENGTH_SHORT).show()
                    return
                }

                val totalMonths = calculateRepaymentPeriod(facilityAmount, annualInterestRate, monthlyInstallment)

                if (totalMonths <= 0) {
                    Toast.makeText(this, "Invalid calculation. Please check your inputs.", Toast.LENGTH_SHORT).show()
                    return
                }

                val calculatedYears = totalMonths / 12
                val calculatedMonths = totalMonths % 12

                // Display result
                binding.tvResultLabel.text = getString(R.string.calculated_repayment_period)
                val resultText = if (calculatedYears > 0 && calculatedMonths > 0) {
                    "$calculatedYears Years $calculatedMonths Months"
                } else if (calculatedYears > 0) {
                    "$calculatedYears Years"
                } else {
                    "$calculatedMonths Months"
                }
                binding.tvResultValue.text = resultText
                binding.tvResultValue.textSize = 24f
                binding.resultContainer.visibility = View.VISIBLE
            }

        } catch (e: NumberFormatException) {
            Toast.makeText(this, getString(R.string.invalid_input), Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(this, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    /**
     * Calculate EMI (Equated Monthly Installment) using the standard formula:
     * EMI = P * [r * (1 + r)^n] / [(1 + r)^n - 1]
     * 
     * Where:
     * P = Principal amount (Facility Amount)
     * r = Monthly interest rate (Annual Interest Rate / 12 / 100)
     * n = Total number of months
     */
    private fun calculateEMI(principal: Double, annualInterestRate: Double, totalMonths: Int): Double {
        if (annualInterestRate == 0.0) {
            // If interest rate is 0, simply divide principal by number of months
            return principal / totalMonths
        }

        // Calculate monthly interest rate
        val monthlyInterestRate = annualInterestRate / 12.0 / 100.0

        // Calculate (1 + r)^n
        val onePlusRToN = (1 + monthlyInterestRate).pow(totalMonths)

        // Calculate EMI
        val emi = principal * (monthlyInterestRate * onePlusRToN) / (onePlusRToN - 1)

        return emi
    }

    /**
     * Calculate Repayment Period (in months) from EMI using reverse formula:
     * n = ln(EMI / (EMI - P * r)) / ln(1 + r)
     * 
     * Where:
     * P = Principal amount (Facility Amount)
     * r = Monthly interest rate (Annual Interest Rate / 12 / 100)
     * EMI = Monthly Installment
     * n = Total number of months
     */
    private fun calculateRepaymentPeriod(principal: Double, annualInterestRate: Double, monthlyInstallment: Double): Int {
        if (annualInterestRate == 0.0) {
            // If interest rate is 0, simply divide principal by monthly installment
            return (principal / monthlyInstallment).toInt()
        }

        // Calculate monthly interest rate
        val monthlyInterestRate = annualInterestRate / 12.0 / 100.0

        // Calculate denominator: EMI - P * r
        val denominator = monthlyInstallment - (principal * monthlyInterestRate)

        if (denominator <= 0) {
            // Invalid calculation - EMI is too low
            return -1
        }

        // Calculate n = ln(EMI / (EMI - P * r)) / ln(1 + r)
        val numerator = monthlyInstallment / denominator
        val totalMonths = ln(numerator) / ln(1 + monthlyInterestRate)

        // Round to nearest integer
        return totalMonths.toInt()
    }
}

