namespace Models.DTO.AuthDTO;

/// <summary>
/// Omotač oko JWT tokena. Token se vraća unutar <c>data</c>, a ne kao golo tijelo odgovora,
/// da bi svaki odgovor API-ja imao isti oblik i da bi se uz token kasnije mogli poslati i
/// dodatni podaci bez lomljenja klijenata.
/// </summary>
public class TokenResponse
{
    public string Token { get; set; } = string.Empty;
}
