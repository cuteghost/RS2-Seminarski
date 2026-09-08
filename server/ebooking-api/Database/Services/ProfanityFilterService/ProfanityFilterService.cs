using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Text.RegularExpressions;

namespace Database.Services.ProfanityFilterService;

public class ProfanityFilterService : IProfanityFilterService
{
    private readonly List<Regex> _bannedWordPatterns;
    private readonly ILogger<ProfanityFilterService> _logger;

    public ProfanityFilterService(IOptions<ProfanityFilterOptions> options, ILogger<ProfanityFilterService> logger)
    {
        _logger = logger;
        _bannedWordPatterns = (options.Value.BannedWords ?? new List<string>())
            .Where(word => !string.IsNullOrWhiteSpace(word))
            .Select(word => new Regex($@"\b{Regex.Escape(word.Trim())}\b", RegexOptions.IgnoreCase | RegexOptions.Compiled))
            .ToList();
    }

    public (string CleanedText, bool WasModified) Filter(string text)
    {
        if (string.IsNullOrEmpty(text))
            return (text ?? string.Empty, false);

        var wasModified = false;
        var cleaned = text;

        foreach (var pattern in _bannedWordPatterns)
        {
            cleaned = pattern.Replace(cleaned, match =>
            {
                wasModified = true;
                return new string('*', match.Value.Length);
            });
        }

        if (wasModified)
            _logger.LogInformation("Komentar recenzije je sadržavao neprimjeren sadržaj i zamijenjen je prije upisa.");

        return (cleaned, wasModified);
    }
}
