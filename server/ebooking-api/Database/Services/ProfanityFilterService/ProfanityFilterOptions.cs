namespace Database.Services.ProfanityFilterService;

public class ProfanityFilterOptions
{
    public List<string> BannedWords { get; set; } = new();
}
