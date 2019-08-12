using System;
using System.Collections.Generic;


namespace Setup.Enrich
{
    public static class EnrichFinancial
    {
        // Returns Dictionary containing enriched financial-table information: debt income ratio, debt income ratio rating, insurance rating, mortgage rating, and utility rating 
        public static Dictionary<String, String> Process(Dictionary<String, String> results, Newtonsoft.Json.Linq.JObject data)
        {
            double monthlyIncome = Enrich.RemoveDollarSignComma(data["totalMonthlyIncome"]);
            results.Add("debtIncomeRatio", ComputeDebtIncomeRatio(data, monthlyIncome));
            results.Add("debtIncomeRatioRating", RateDebtIncomeRatio(data, monthlyIncome));
            results.Add("insuranceRating", RateInsurance(data, monthlyIncome));
            results.Add("utilityRating", RateUtility(data, monthlyIncome));
            results.Add("mortgageRating", RateMortgage(data, monthlyIncome));
            return results;
        }

        // Returns letter rating representing the percentage of monthly income spent on utilities: A: <2%, B: 2-5%, C: 5-8%, D: 8-10%, F: >10%
        public static string RateUtility(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            double phone = Enrich.RemoveDollarSignComma(data["phone"]);
            double electricity = Enrich.RemoveDollarSignComma(data["electricity"]);
            if (phone == -1 || electricity == -1 || monthlyIncome == -1) return null;
            double percentage = (phone + electricity) / monthlyIncome;
            return rate(percentage * 100, 2, 5, 8, 10);
        }

        // Returns letter rating representing the percentage of monthly income spent on utilities: A: <2%, B: 2-5%, C: 5-8%, D: 8-10%, F: >10%
        public static string RateInsurance(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            double insurance = Enrich.RemoveDollarSignComma(data["insuranceSubtotal"]);
            if (insurance == -1 || monthlyIncome == -1) return null;
            double percentage = insurance / monthlyIncome;
            return rate(percentage * 100, 2, 3, 4, 5);
        }

        /* 
        Returns letter rating representing the percentage of monthly income spent on debt: A: <10%, B: 10-20%, C: 20-30%, D: 30-36%, F: >36%
        Debt includes total amount of monthly loans as well as mortgage/rent
        */
        public static string RateDebtIncomeRatio(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            string debtIncomeRatio = ComputeDebtIncomeRatio(data, monthlyIncome);
            if (debtIncomeRatio == null) return null;
            return rate(Double.Parse(debtIncomeRatio) * 100, 10, 20, 30, 36);
        }

        // Returns letter rating representing the percentage of monthly income spent on mortgage/rent: A: <10%, B: 10-20%, C: 20-24%, D: 24-28%, F: >28%
        public static string RateMortgage(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            double mortgage = Enrich.RemoveDollarSignComma(data["mortgageOrRent"]);
            if (mortgage == -1 || monthlyIncome == -1) return null;
            double percentage = mortgage / monthlyIncome;
            return rate(percentage * 100, 10, 20, 24, 28);
        }

        // Returns debt to income ratio: debt includes total amount of monthly income spent on loans/mortage/rent
        public static string ComputeDebtIncomeRatio(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            double loanTotal = Enrich.RemoveDollarSignComma(data["loansSubtotal"]);
            double mortgage = Enrich.RemoveDollarSignComma(data["mortgageOrRent"]);
            if (loanTotal == -1 || mortgage == -1 || monthlyIncome == -1) return null;
            double debtRatio = (loanTotal + mortgage) / monthlyIncome;
            return debtRatio.ToString().Substring(0, 4);
        }

        // Returns letter rating based on given value and letter rating ranges
        public static string rate(double value, int A, int B, int C, int D)
        {
            string rating;
            if (value <= A)
            {
                rating = "A";
            }
            else if (value > A && value <= B)
            {
                rating = "B";
            }
            else if (value > B && value <= C)
            {
                rating = "C";
            }
            else if (value > C && value <= D)
            {
                rating = "D";
            }
            else
            {
                rating = "F";
            }
            return rating;
        }

    }
}