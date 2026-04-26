namespace DotShutdown.Models;

/// <summary>
/// Application settings model for JSON serialization.
/// </summary>
public class AppSettings
{
    public string LastAction { get; set; } = nameof(PowerActionType.Shutdown);
    public int LastMinutes { get; set; } = 30;
    public bool ForceClose { get; set; } = false;
    public bool SoundAlert { get; set; } = true;
    public int AlertBeforeSeconds { get; set; } = 60;
    public bool MinimizeToTray { get; set; } = true;
    public bool ConfirmBeforeAction { get; set; } = true;
    public bool LaunchAtStartup { get; set; } = false;
    public string Theme { get; set; } = "System"; // System / Light / Dark

    public PowerActionType LastActionType
    {
        get => Enum.TryParse<PowerActionType>(LastAction, out var result)
            ? result
            : PowerActionType.Shutdown;
        set => LastAction = value.ToString();
    }
}
