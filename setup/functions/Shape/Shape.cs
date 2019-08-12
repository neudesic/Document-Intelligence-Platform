/*
Receives the http response from the Form Recognizer REST api and shapes it into an easy to read json
 */


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
            
            // Populates Form class with data from Form Recognizer REST api response
            Form data = JsonConvert.DeserializeObject<Form>(requestBody);
            
            // Relevant model is created (w2 or financial table)
            Model model = ChooseModel(req.Headers["Form-Type"]);

            // Populates the model
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
                // If an error occurs or Form Recognizer does not send back any data, an empty model is returned
                model = new Model();
            }

            return (IActionResult)new OkObjectResult(model?.RemoveProperty("populateInformation"));
        }

        // Creates an instance of a model depending on the value of the http header "Form-Type"
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
