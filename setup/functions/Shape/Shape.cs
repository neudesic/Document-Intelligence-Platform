using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;


namespace Setup.Shape
{
    public class Shape
    {
        [FunctionName("Shape")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            Form data = JsonConvert.DeserializeObject<Form>(requestBody);
            Model model = ChooseModel(req.Headers["Form-Type"]);

            try
            {
                if (data != null)
                {
                    foreach (Page page in data.Pages)
                    {
                        foreach (KeyValuePair keyValue in page.KeyValuePairs)
                        {
                            model?.PopulateModel(keyValue, model, model.populateInformation);
                        }
                    }
                }
            }
            catch
            {
                model = new Model();
            }

            return (IActionResult)new OkObjectResult(model?.RemoveProperty("populateInformation"));
        }

        public static Model ChooseModel(String header)
        {
            if (header == "W2")
            {
                return new W2Model();
            }
            else if (header == "Financial Table")
            {
                return new FinancialTableModel();
            }
            return null;
        }

    }
}
