namespace Services.FacebookService;

public class FacebookAuthConfig
{
    public string TokenValidationUrl { get; set; } = "debug_token?input_token={0}&access_token={1}|{2}";

    public string UserInfoUrl { get; set; } = "me?fields=id,name,first_name,last_name,email,picture.type(large)&access_token={0}";

    public string AppId { get; set; } = string.Empty;

    public string AppSecret { get; set; } = string.Empty;
}
