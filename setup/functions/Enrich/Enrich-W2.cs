using System;
using System.Collections.Generic;


namespace Setup.Enrich
{
    public static class EnrichW2
    {
        public static Dictionary<String, String> Process(Dictionary<String, String> results, Newtonsoft.Json.Linq.JObject data)
        {
            results.Add("disposableIncome", ComputeDisposableIncome(data));
            return results;
        }

        public static string ComputeDisposableIncome(Newtonsoft.Json.Linq.JObject data)
        {
            double compensation = Enrich.RemoveDollarSignComma(data["compensation"]);
            double federalIncomeTaxWithheld = Enrich.RemoveDollarSignComma(data["federalIncomeTaxWithheld"]);
            double ssTaxWithheld = Enrich.RemoveDollarSignComma(data["ssTaxWithheld"]);
            double medicareTaxWithheld = Enrich.RemoveDollarSignComma(data["medicareTaxWithheld"]);
            if (compensation == -1 || federalIncomeTaxWithheld == -1 || ssTaxWithheld == -1 || medicareTaxWithheld == -1) return null;
            double disposableIncome = compensation - federalIncomeTaxWithheld - ssTaxWithheld - medicareTaxWithheld;
            return disposableIncome.ToString();
        }

    }
}