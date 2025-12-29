using System.Text.Json.Serialization;
using System.Collections.Generic;

public class GoogleUserInfoResponse
{
    [JsonPropertyName("resourceName")]
    public string ResourceName { get; set; }

    [JsonPropertyName("etag")]
    public string Etag { get; set; }

    [JsonPropertyName("genders")]
    public List<GoogleGender> Genders { get; set; }

    [JsonPropertyName("birthdays")]
    public List<Birthday> Birthdays { get; set; }
}

public class GoogleGender
{
    [JsonPropertyName("metadata")]
    public Metadata Metadata { get; set; }

    [JsonPropertyName("value")]
    public string Value { get; set; }

    [JsonPropertyName("formattedValue")]
    public string FormattedValue { get; set; }
}

public class Birthday
{
    [JsonPropertyName("metadata")]
    public Metadata Metadata { get; set; }

    [JsonPropertyName("date")]
    public Date Date { get; set; }
}

public class Metadata
{
    [JsonPropertyName("primary")]
    public bool? Primary { get; set; }  // nullable for optional JSON fields

    [JsonPropertyName("source")]
    public Source Source { get; set; }
}

public class Source
{
    [JsonPropertyName("type")]
    public string Type { get; set; }

    [JsonPropertyName("id")]
    public string Id { get; set; }
}

public class Date
{
    [JsonPropertyName("year")]
    public int Year { get; set; }

    [JsonPropertyName("month")]
    public int Month { get; set; }

    [JsonPropertyName("day")]
    public int Day { get; set; }
}