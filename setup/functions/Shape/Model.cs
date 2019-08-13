/*
Base class containing all of the methods and instance variables required by W2-Model and Financial-Table-Model
 */

using Newtonsoft.Json;
using System;


namespace Setup.Shape
{
    public class Model
    {
        public KeyText[] populateInformation;

        public class KeyText
        {
            public string key;
            public string text;

            // Class representing key/value pairs for model
            public KeyText(string key, string text)
            {
                this.key = key;
                this.text = text;
            }
        }

        // Converts json to string
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }

        // Populates the model using inputted key/value pairs from the Form class 
        public void PopulateModel(KeyValuePair keyValue, Model model, KeyText[] information)
        {
            foreach (KeyText pair in information)
            {
                if (keyValue.ContainsKey(pair.text))
                {
                    dynamic property = model.GetType().GetProperty(pair.key);
                    property.SetValue(model, keyValue.ConcatValues());
                }
            }
        }

        // Removes a specified field from a json object
        public Newtonsoft.Json.Linq.JObject RemoveProperty(String property)
        {
            var json = (Newtonsoft.Json.Linq.JObject)JsonConvert.DeserializeObject(this.ToString());
            json.Property(property).Remove();
            return json;
        }

    }
}