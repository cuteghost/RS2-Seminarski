namespace Models.Domain;

public class BaseResponse<T>
{
    public string Message { get; set; }
    public bool IsSuccess { get; set; }
    public T Data { get; set; }

    public BaseResponse(string message, bool isSuccess, T data)
    {
        Message = message;
        IsSuccess = isSuccess;
        Data = data;
    }
}
