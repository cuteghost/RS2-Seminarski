using Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.SqlServer.Server;
using Microsoft.VisualBasic;
using Models.Domain;
using Models.DTO.AuthDTO;
using Models.Models.Domain;
using Repository.Interfaces;
using Authentication.Services.HashService;
using System.Globalization;
using static Google.Apis.Auth.GoogleJsonWebSignature;

namespace API.Repository.Classes;

public class LoginRepository : ILoginRepository
{
    private readonly ApplicationDbContext _dbContext;
    private readonly IHashService _hasher;
    private readonly ICustomerRepository _customerRepository;
    public LoginRepository(ApplicationDbContext dbContext, IHashService hasher, ICustomerRepository customerRepository)
    {
        _dbContext = dbContext;
        _hasher = hasher;
        _customerRepository = customerRepository;

    }

    public async Task<User> FacebookLogin(FacebookUserInfoResponse userInfo)
    {
        var dbUser = await _dbContext.Users.AsNoTracking().Where(s => s.Email == userInfo.Email).FirstOrDefaultAsync();
        // Check if user exists. If not, create a new user
        if (dbUser == null)
        {
            var image = userInfo.Picture.Data.Url.ToString();
            HttpClient client = new HttpClient();
            var response = await client.GetAsync(image);
            byte[] imageBytes = await response.Content.ReadAsByteArrayAsync();
            string dateFormat = "MM/dd/yyyy";

            var user = new User
            {
                DisplayName = userInfo.FirstName + " " + userInfo.LastName,
                Email = userInfo.Email,
                FirstName = userInfo.FirstName,
                LastName = userInfo.LastName,
                BirthDate = DateTime.ParseExact(userInfo.birthday, dateFormat, CultureInfo.InvariantCulture),
                Password = _hasher.Hash(Guid.NewGuid().ToString()),
                Image = imageBytes,
                IsDeleted = false,
                SocialLink = "Facebook",
            };
            await _customerRepository.AddCustomer(user, new Customer());
            return user;
        }
        // User exists
        else if (dbUser.IsDeleted == true)
        {
            var image = userInfo.Picture.Data.Url.ToString();
            HttpClient client = new HttpClient();
            var response = await client.GetAsync(image);
            byte[] imageBytes = await response.Content.ReadAsByteArrayAsync();
            string dateFormat = "MM/dd/yyyy";

            dbUser.DisplayName = userInfo.FirstName + " " + userInfo.LastName;
            dbUser.BirthDate = DateTime.ParseExact(userInfo.birthday, dateFormat, CultureInfo.InvariantCulture);
            dbUser.Email = userInfo.Email;
            dbUser.FirstName = userInfo.FirstName;
            dbUser.LastName = userInfo.LastName;
            dbUser.Password = _hasher.Hash(Guid.NewGuid().ToString());
            dbUser.Image = imageBytes;
            dbUser.IsDeleted = false;
            dbUser.SocialLink = "Facebook";

            var customer = _dbContext.Customers.Where(c => c.User.Id == dbUser.Id).FirstOrDefault();
            customer.IsDeleted = false;
            customer.User = dbUser;
            await _dbContext.SaveChangesAsync();
            return dbUser;
        }
        else
            return dbUser;
    }

    public async Task<User> GoogleLogin(Payload payload, GoogleUserInfoResponse data)
    {

        var dbUser = await _dbContext.Users.AsNoTracking().Where(s => s.Email == payload.Email).FirstOrDefaultAsync();
        string dateFormat = "MM/dd/yyyy";
        DateTime date = DateTime.ParseExact((data.Birthdays[0].Date.Month < 10 ? "0" + data.Birthdays[0].Date.Month.ToString() : data.Birthdays[0].Date.Month.ToString()) + "/" + 
                                            (data.Birthdays[0].Date.Day < 10 ? "0" + data.Birthdays[0].Date.Day.ToString() : data.Birthdays[0].Date.Day.ToString()) + "/" + 
                                            data.Birthdays[0].Date.Year.ToString(), dateFormat, CultureInfo.InvariantCulture);
        if (dbUser == null)
        {
            HttpClient client = new HttpClient();
            var imageResponse = await client.GetAsync(payload.Picture);
            var imageBytes = await imageResponse.Content.ReadAsByteArrayAsync();

            var userToBeCreated = new User
            {
                DisplayName = payload.Name,
                FirstName = payload.GivenName,
                LastName = payload.FamilyName,
                Email = payload.Email,
                Image = imageBytes,
                Gender = data.Genders[0].Value == "male" ? Gender.Male: Gender.Female,
                BirthDate = date,
                SocialLink = "Google"
            };

            var customer = new Customer
            {
                User = userToBeCreated
            };
            await _customerRepository.AddCustomer(userToBeCreated, customer);
            return userToBeCreated;
        }
        else if (dbUser.IsDeleted == true)
        {
            HttpClient client = new HttpClient();
            var imageResponse = await client.GetAsync(payload.Picture);
            var imageBytes = await imageResponse.Content.ReadAsByteArrayAsync();
             
            dbUser.DisplayName = payload.Name;
            dbUser.FirstName = payload.GivenName;
            dbUser.LastName = payload.FamilyName;
            dbUser.Email = payload.Email;
            dbUser.Image = imageBytes;
            dbUser.SocialLink = "Google";
            dbUser.Gender = data.Genders[0].Value == "male" ? Gender.Male : Gender.Female;
            dbUser.BirthDate = date;
            dbUser.IsDeleted = false;

            var customer = _dbContext.Customers.Where(c => c.User.Id == dbUser.Id).FirstOrDefault();
            customer.IsDeleted = false;
            customer.User = dbUser;
            await _dbContext.SaveChangesAsync();
            return dbUser;
        }
        else
            return dbUser;
    }

    public async Task<User> Login(LoginDTO user)
    {
        user.Password = _hasher.Hash(user.Password);
        var _user = await _dbContext.Users.AsNoTracking().Where(s => s.Email == user.Email && s.Password == user.Password).FirstOrDefaultAsync();
        if (_user != null)
            return _user;

        return null;
    }

}
