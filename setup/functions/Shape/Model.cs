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

            public KeyText(string key, string text)
            {
                this.key = key;
                this.text = text;
            }
        }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }

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

        public Newtonsoft.Json.Linq.JObject RemoveProperty(String property)
        {
            var json = (Newtonsoft.Json.Linq.JObject)JsonConvert.DeserializeObject(this.ToString());
            json.Property(property).Remove();
            return json;
        }

    }
}