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


namespace Setup.Enrich
{
    public static class Enrich
    {
        [FunctionName("Enrich")]
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
                String header = req.Headers["Form-Type"];

                if (header == "Financial Table")
                {
                    results = EnrichFinancial.Process(results, data);
                }
                else if (header == "W2")
                {
                    results = EnrichW2.Process(results, data);
                }
            }
            catch
            {
                results = new Dictionary<String, String>();
            }

            return (IActionResult)new OkObjectResult(results);
        }

        public static double RemoveDollarSignComma(dynamic data)
        {
            if (data == null) return -1;
            string value = data.ToString().Replace("$", "").Replace(",", "");
            return value == "" ? -1 : Double.Parse(value);
        }

    }
}