using System.Globalization;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;


namespace Setup.Shape
{

    public partial class Form
    {
        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("pages")]
        public Page[] Pages { get; set; }

        [JsonProperty("errors")]
        public object[] Errors { get; set; }
    }

    public partial class Page
    {
        [JsonProperty("number")]
        public long Number { get; set; }

        [JsonProperty("height")]
        public long Height { get; set; }

        [JsonProperty("width")]
        public long Width { get; set; }

        [JsonProperty("clusterId")]
        public long ClusterId { get; set; }

        [JsonProperty("keyValuePairs")]
        public KeyValuePair[] KeyValuePairs { get; set; }

        [JsonProperty("tables")]
        public Table[] Tables { get; set; }
    }

    public partial class KeyValuePair
    {
        [JsonProperty("key")]
        public Key[] Key { get; set; }

        [JsonProperty("value")]
        public Value[] Value { get; set; }

        public bool ContainsKey(String text)
        {
            return Key[0].Text.ToLower().Contains(text.ToLower());
        }

        public string ConcatValues()
        {
            string result = "";
            foreach (Value value in Value)
            {
                result += value.Text + " ";
            }
            return result.Length > 0 ? result.Substring(0, result.Length - 1) : result;
        }
    }

    public partial class Key
    {
        [JsonProperty("text")]
        public string Text { get; set; }

        [JsonProperty("boundingBox")]
        public double[] BoundingBox { get; set; }
    }

    public partial class Value
    {
        [JsonProperty("text")]
        public string Text { get; set; }

        [JsonProperty("boundingBox")]
        public double[] BoundingBox { get; set; }

        [JsonProperty("confidence")]
        public double Confidence { get; set; }
    }

    public partial class Table
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("columns")]
        public Column[] Columns { get; set; }
    }

    public partial class Column
    {
        [JsonProperty("header")]
        public Key[] Header { get; set; }

        [JsonProperty("entries")]
        public Value[][] Entries { get; set; }
    }

    public partial class Form
    {
        public static Form FromJson(string json) => JsonConvert.DeserializeObject<Form>(json, Setup.Shape.Converter.Settings);
    }

    public static class Serialize
    {
        public static string ToJson(this Form self) => JsonConvert.SerializeObject(self, Setup.Shape.Converter.Settings);
    }

    internal static class Converter
    {
        public static readonly JsonSerializerSettings Settings = new JsonSerializerSettings
        {
            MetadataPropertyHandling = MetadataPropertyHandling.Ignore,
            DateParseHandling = DateParseHandling.None,
            Converters = {
                new IsoDateTimeConverter { DateTimeStyles = DateTimeStyles.AssumeUniversal }
            },
        };
    }

}
