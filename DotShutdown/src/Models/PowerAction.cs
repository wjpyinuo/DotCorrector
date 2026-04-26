namespace DotShutdown.Models;

/// <summary>
/// Available power actions.
/// </summary>
public enum PowerActionType
{
    Shutdown,
    Restart,
    Sleep,
    Hibernate,
    LogOff
}

/// <summary>
/// Extension methods for PowerActionType.
/// </summary>
public static class PowerActionExtensions
{
    public static string ToDisplayName(this PowerActionType action) => action switch
    {
        PowerActionType.Shutdown  => "关机",
        PowerActionType.Restart   => "重启",
        PowerActionType.Sleep     => "睡眠",
        PowerActionType.Hibernate => "休眠",
        PowerActionType.LogOff    => "注销",
        _ => action.ToString()
    };

    public static string ToIcon(this PowerActionType action) => action switch
    {
        PowerActionType.Shutdown  => "\u23FB",  // ⏻
        PowerActionType.Restart   => "\U0001F504", // 🔄
        PowerActionType.Sleep     => "\U0001F319", // 🌙
        PowerActionType.Hibernate => "\U0001F4A4", // 💤
        PowerActionType.LogOff    => "\U0001F6AA", // 🚪
        _ => "⚡"
    };

    public static string ToEnglishName(this PowerActionType action) => action switch
    {
        PowerActionType.Shutdown  => "Shutdown",
        PowerActionType.Restart   => "Restart",
        PowerActionType.Sleep     => "Sleep",
        PowerActionType.Hibernate => "Hibernate",
        PowerActionType.LogOff    => "Log Off",
        _ => action.ToString()
    };
}
