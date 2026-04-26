namespace DotShutdown.Helpers;

/// <summary>
/// Parses flexible time strings like "30", "45m", "2h", "1h30m", "90s".
/// </summary>
public static partial class TimeParser
{
    private static readonly System.Text.RegularExpressions.Regex HourRegex =
        new(@"(\d+)h", System.Text.RegularExpressions.RegexOptions.Compiled);
    private static readonly System.Text.RegularExpressions.Regex MinRegex =
        new(@"(\d+)m", System.Text.RegularExpressions.RegexOptions.Compiled);
    private static readonly System.Text.RegularExpressions.Regex SecRegex =
        new(@"(\d+)s", System.Text.RegularExpressions.RegexOptions.Compiled);

    /// <summary>
    /// Parse a time string into total seconds.
    /// Supports: "30" (minutes), "45m", "2h", "1h30m", "90s", "1h30m45s"
    /// </summary>
    public static int Parse(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return 0;

        input = input.Trim().ToLowerInvariant();
        int total = 0;

        var hMatch = HourRegex.Match(input);
        var mMatch = MinRegex.Match(input);
        var sMatch = SecRegex.Match(input);

        if (hMatch.Success || mMatch.Success || sMatch.Success)
        {
            if (hMatch.Success) total += int.Parse(hMatch.Groups[1].Value) * 3600;
            if (mMatch.Success) total += int.Parse(mMatch.Groups[1].Value) * 60;
            if (sMatch.Success) total += int.Parse(sMatch.Groups[1].Value);
        }
        else
        {
            // Plain number = minutes
            if (int.TryParse(input, out int minutes))
                total = minutes * 60;
        }

        return total;
    }

    /// <summary>
    /// Format seconds to HH:MM:SS.
    /// </summary>
    public static string FormatHMS(int totalSeconds)
    {
        var ts = TimeSpan.FromSeconds(Math.Max(0, totalSeconds));
        return $"{(int)ts.TotalHours:D2}:{ts.Minutes:D2}:{ts.Seconds:D2}";
    }

    /// <summary>
    /// Format seconds to human-readable Chinese text.
    /// </summary>
    public static string FormatChinese(int totalSeconds)
    {
        if (totalSeconds <= 0) return "0秒";
        var ts = TimeSpan.FromSeconds(totalSeconds);
        var parts = new List<string>();
        if (ts.Hours > 0) parts.Add($"{ts.Hours}小时");
        if (ts.Minutes > 0) parts.Add($"{ts.Minutes}分钟");
        if (ts.Seconds > 0 && ts.Hours == 0) parts.Add($"{ts.Seconds}秒");
        return parts.Count > 0 ? string.Join("", parts) : "不到1秒";
    }
}

