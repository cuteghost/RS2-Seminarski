namespace Models.Domain;

public class BaseResponse<T>
{
    public string Message { get; set; }
    public T Data { get; set; }

    public BaseResponse(string message, T data)
    {
        Message = message;
        Data = data;
    }
}
