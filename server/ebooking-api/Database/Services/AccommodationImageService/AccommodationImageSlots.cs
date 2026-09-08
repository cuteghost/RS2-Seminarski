namespace Database.Services.AccommodationImageService;

public class AccommodationImageSlots
{
    public Guid AccommodationId { get; set; }

    public bool Has1 { get; set; }
    public bool Has2 { get; set; }
    public bool Has3 { get; set; }
    public bool Has4 { get; set; }
    public bool Has5 { get; set; }
    public bool Has6 { get; set; }
    public bool Has7 { get; set; }
    public bool Has8 { get; set; }
    public bool Has9 { get; set; }
    public bool Has10 { get; set; }
    public bool Has11 { get; set; }
    public bool Has12 { get; set; }
    public bool Has13 { get; set; }
    public bool Has14 { get; set; }
    public bool Has15 { get; set; }
    public bool Has16 { get; set; }
    public bool Has17 { get; set; }
    public bool Has18 { get; set; }
    public bool Has19 { get; set; }
    public bool Has20 { get; set; }

    public List<int> Indexes()
    {
        var indexes = new List<int>();
        var flags = new[] { Has1, Has2, Has3, Has4, Has5, Has6, Has7, Has8, Has9, Has10, Has11, Has12, Has13, Has14, Has15, Has16, Has17, Has18, Has19, Has20 };

        for (var i = 0; i < flags.Length; i++)
        {
            if (flags[i])
                indexes.Add(i + 1);
        }

        return indexes;
    }
}
