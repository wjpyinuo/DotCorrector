namespace DotShutdown.Models;

/// <summary>
/// Represents a scheduled power action with target time.
/// </summary>
public class ScheduleTask
{
    public PowerActionType Action { get; set; }
    public DateTime ScheduledTime { get; set; }
    public bool ForceClose { get; set; }
    public bool IsActive { get; set; }

    public TimeSpan Remaining => ScheduledTime - DateTime.Now;

    public string RemainingText
    {
        get
        {
            var ts = Remaining;
            if (ts.TotalSeconds <= 0) return "00:00:00";
            return $"{(int)ts.TotalHours:D2}:{ts.Minutes:D2}:{ts.Seconds:D2}";
        }
    }

    public string RemainingHumanized
    {
        get
        {
            var ts = Remaining;
            if (ts.TotalSeconds <= 0) return "即将执行";
            var parts = new List<string>();
            if (ts.Hours > 0) parts.Add($"{ts.Hours}小时");
            if (ts.Minutes > 0) parts.Add($"{ts.Minutes}分钟");
            if (ts.Seconds > 0 && ts.Hours == 0) parts.Add($"{ts.Seconds}秒");
            return parts.Count > 0 ? string.Join(" ", parts) : "不到1秒";
        }
    }
}
