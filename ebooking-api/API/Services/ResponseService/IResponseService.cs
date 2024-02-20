using Microsoft.AspNetCore.Mvc;

namespace Services.ResponseService;
    public interface IResponseService
    {
        public Task<IActionResult> Response(int code, object returnobj);

    }