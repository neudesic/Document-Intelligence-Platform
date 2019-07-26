using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Collections.Generic;


namespace Setup.Process
{
    public static class Process
    {
        [FunctionName("Process")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");
            Dictionary<String, String> results = new Dictionary<String, String>();

            try
            {
                string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                Newtonsoft.Json.Linq.JObject data = (Newtonsoft.Json.Linq.JObject)JsonConvert.DeserializeObject(requestBody);
                var financial = data["financial-table"]["form"];
                var financialEnriched = data["financial-table-enriched"]["results"];
                var w2 = data["w2-form"]["form"];
                var w2Enriched = data["w2-form-enriched"]["results"];
                results = ComputeForecasts(results, financial, financialEnriched, w2, w2Enriched);
            }
            catch
            {
                results = new Dictionary<String, String>();
            }

            return (IActionResult)new OkObjectResult(results);
        }


        public static Dictionary<String, String> ComputeForecasts(Dictionary<String, String> results, Newtonsoft.Json.Linq.JToken financial, Newtonsoft.Json.Linq.JToken financialEnriched, Newtonsoft.Json.Linq.JToken w2, Newtonsoft.Json.Linq.JToken w2Enriched)
        {
            double disposableIncome = RemoveDollarSignComma(w2Enriched["disposableIncome"]);
            double extraIncome = RemoveDollarSignComma(financial["extraIncome"]);
            double disposablePlusExtraIncome;
            if (disposableIncome == -1 || extraIncome == -1) { disposablePlusExtraIncome = -1; }
            else
            {
                disposablePlusExtraIncome = disposableIncome + (extraIncome * 12);
            }
            results.Add("yearlyMortageForecast", ComputeMortgageForecast(financial, disposablePlusExtraIncome));
            results.Add("yearlyUtilityForecast", ComputeUtilityForecast(financial, disposablePlusExtraIncome));
            results.Add("yearlyLoansForecast", ComputeLoansForecast(financial, disposablePlusExtraIncome));
            results.Add("yearlyInsuranceForecast", ComputeInsuranceForecast(financial, disposablePlusExtraIncome));
            results.Add("yearlyNetForecast", ComputeNetForecast(financial, disposablePlusExtraIncome));
            return results;
        }

        public static String ComputeMortgageForecast(Newtonsoft.Json.Linq.JToken financial, double incomeTotal)
        {
            double mortgage = RemoveDollarSignComma(financial["mortgageOrRent"]);
            if (mortgage == -1 || incomeTotal == -1) return null;
            return ((mortgage * 12) / incomeTotal).ToString().Substring(0, 4);
        }

        public static String ComputeUtilityForecast(Newtonsoft.Json.Linq.JToken financial, double incomeTotal)
        {
            double electricty = RemoveDollarSignComma(financial["electricity"]);
            double phone = RemoveDollarSignComma(financial["phone"]);
            if (electricty == -1 || phone == -1 || incomeTotal == -1) return null;
            return (((electricty + phone) * 12) / incomeTotal).ToString().Substring(0, 4);
        }

        public static String ComputeLoansForecast(Newtonsoft.Json.Linq.JToken financial, double incomeTotal)
        {
            double loans = RemoveDollarSignComma(financial["loansSubtotal"]);
            if (loans == -1 || incomeTotal == -1) return null;
            return ((loans * 12) / incomeTotal).ToString().Substring(0, 4);
        }

        public static String ComputeInsuranceForecast(Newtonsoft.Json.Linq.JToken financial, double incomeTotal)
        {
            double insurance = RemoveDollarSignComma(financial["insuranceSubtotal"]);
            if (insurance == -1 || incomeTotal == -1) return null;
            return ((insurance * 12) / incomeTotal).ToString().Substring(0, 4);
        }

        public static String ComputeNetForecast(Newtonsoft.Json.Linq.JToken financial, double incomeTotal)
        {
            double totalCost = RemoveDollarSignComma(financial["totalActualCost"]);
            if (incomeTotal == -1 || totalCost == -1) return null;
            return (incomeTotal - (totalCost * 12)).ToString();
        }

        public static double RemoveDollarSignComma(dynamic data)
        {
            if (data == null) return -1;
            string value = data.ToString().Replace("$", "").Replace(",", "");
            return value == "" ? -1 : Double.Parse(value);
        }

    }
}

