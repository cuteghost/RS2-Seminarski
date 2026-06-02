namespace Database.Services.ProfanityFilterService;

public interface IProfanityFilterService
{
    (string CleanedText, bool WasModified) Filter(string text);
}
