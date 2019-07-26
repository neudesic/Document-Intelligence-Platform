using System;
using System.Collections.Generic;


namespace Setup.Enrich
{
    public static class EnrichFinancial
    {
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

        public static string RateUtility(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            double phone = Enrich.RemoveDollarSignComma(data["phone"]);
            double electricity = Enrich.RemoveDollarSignComma(data["electricity"]);
            if (phone == -1 || electricity == -1 || monthlyIncome == -1) return null;
            double percentage = (phone + electricity) / monthlyIncome;
            return rate(percentage * 100, 2, 5, 8, 10);
        }

        public static string RateInsurance(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            double insurance = Enrich.RemoveDollarSignComma(data["insuranceSubtotal"]);
            if (insurance == -1 || monthlyIncome == -1) return null;
            double percentage = insurance / monthlyIncome;
            return rate(percentage * 100, 2, 3, 4, 5);
        }

        public static string RateDebtIncomeRatio(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            string debtIncomeRatio = ComputeDebtIncomeRatio(data, monthlyIncome);
            if (debtIncomeRatio == null) return null;
            return rate(Double.Parse(debtIncomeRatio) * 100, 10, 20, 30, 36);
        }

        public static string RateMortgage(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            double mortgage = Enrich.RemoveDollarSignComma(data["mortgageOrRent"]);
            if (mortgage == -1 || monthlyIncome == -1) return null;
            double percentage = mortgage / monthlyIncome;
            return rate(percentage * 100, 10, 20, 24, 28);
        }

        public static string ComputeDebtIncomeRatio(Newtonsoft.Json.Linq.JObject data, double monthlyIncome)
        {
            double loanTotal = Enrich.RemoveDollarSignComma(data["loansSubtotal"]);
            double mortgage = Enrich.RemoveDollarSignComma(data["mortgageOrRent"]);
            if (loanTotal == -1 || mortgage == -1 || monthlyIncome == -1) return null;
            double debtRatio = (loanTotal + mortgage) / monthlyIncome;
            return debtRatio.ToString().Substring(0, 4);
        }

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