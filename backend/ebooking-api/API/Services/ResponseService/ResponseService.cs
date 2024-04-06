using Microsoft.AspNetCore.Mvc;
namespace Services.ResponseService;
    public class ResponseService : Controller, IResponseService
    {
        //TODO: Update If necessary
        public new async Task<IActionResult> Response(int code, object returnobj)
        {
            switch (code)
            {
                case 200:
                    return await Task.FromResult(StatusCode(StatusCodes.Status200OK, returnobj));
                case 201: 
                    return await Task.FromResult(StatusCode(StatusCodes.Status201Created, returnobj));
                case 204: 
                    return await Task.FromResult(StatusCode(StatusCodes.Status204NoContent, returnobj));
                case 400: 
                    return await Task.FromResult(StatusCode(StatusCodes.Status400BadRequest, returnobj));
                case 401: 
                    return await Task.FromResult(StatusCode(StatusCodes.Status401Unauthorized, returnobj));
                case 404: 
                    return await Task.FromResult(StatusCode(StatusCodes.Status404NotFound, returnobj));
                case 405: 
                    return await Task.FromResult(StatusCode(StatusCodes.Status405MethodNotAllowed, returnobj));
                default:
                    return await Task.FromResult(StatusCode(StatusCodes.Status404NotFound, returnobj));
            }
        }
    }
