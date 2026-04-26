namespace DotShutdown.Helpers;

/// <summary>
/// Command-line argument parser for CLI mode.
/// </summary>
public static class CliParser
{
    public class CliArgs
    {
        public bool IsCliMode { get; set; }
        public bool Cancel { get; set; }
        public bool Status { get; set; }
        public string? TimeString { get; set; }
        public string Action { get; set; } = "shutdown";
        public bool Force { get; set; }
        public bool ShowHelp { get; set; }
        public bool ShowVersion { get; set; }
    }

    public static CliArgs Parse(string[] args)
    {
        var result = new CliArgs();

        for (int i = 0; i < args.Length; i++)
        {
            var arg = args[i].ToLowerInvariant();

            switch (arg)
            {
                case "--cli":
                    result.IsCliMode = true;
                    break;
                case "--cancel":
                    result.IsCliMode = true;
                    result.Cancel = true;
                    break;
                case "--status":
                    result.IsCliMode = true;
                    result.Status = true;
                    break;
                case "-t" or "--time":
                    if (i + 1 < args.Length)
                        result.TimeString = args[++i];
                    break;
                case "-a" or "--action":
                    if (i + 1 < args.Length)
                        result.Action = args[++i].ToLowerInvariant();
                    break;
                case "-f" or "--force":
                    result.Force = true;
                    break;
                case "-h" or "--help":
                    result.IsCliMode = true;
                    result.ShowHelp = true;
                    break;
                case "-v" or "--version":
                    result.IsCliMode = true;
                    result.ShowVersion = true;
                    break;
            }
        }

        return result;
    }

    public static void PrintHelp()
    {
        Console.WriteLine("""
            DotShutdown - Windows Auto Shutdown Utility

            Usage: DotShutdown.exe [options]

            Options:
              --cli                 Run in CLI mode (no GUI)
              -t, --time <value>    Delay time: 30, 45m, 2h, 1h30m
              -a, --action <type>   Action: shutdown, restart, logoff, sleep, hibernate
              -f, --force           Force close applications
              --cancel              Cancel pending shutdown/restart
              --status              Check pending shutdown status
              -v, --version         Show version
              -h, --help            Show this help

            Examples:
              DotShutdown.exe                          Launch GUI
              DotShutdown.exe --cli -t 30              Shutdown in 30 minutes
              DotShutdown.exe --cli -t 2h -a restart   Restart in 2 hours
              DotShutdown.exe --cli -t 45m -f          Force shutdown in 45 minutes
              DotShutdown.exe --cli --cancel           Cancel pending shutdown
            """);
    }

    public static void PrintVersion()
    {
        Console.WriteLine("DotShutdown v1.0.0");
    }

    public static int Execute(CliArgs args)
    {
        var power = new Services.PowerService();
        power.EnableShutdownPrivilege();

        if (args.Cancel)
        {
            power.CancelPending();
            Console.WriteLine("✔ 已取消待执行的关机/重启计划。");
            return 0;
        }

        if (args.Status)
        {
            var hasPending = power.HasScheduledShutdown;
            Console.WriteLine(hasPending
                ? "⚠ 有待执行的关机/重启计划！"
                : "当前没有待执行的关机/重启计划。");
            return 0;
        }

        if (string.IsNullOrEmpty(args.TimeString))
        {
            Console.Error.WriteLine("错误: CLI 模式需要指定时间参数 (-t)");
            return 1;
        }

        int seconds = TimeParser.Parse(args.TimeString);
        if (seconds <= 0)
        {
            Console.Error.WriteLine("错误: 无效的时间格式");
            return 1;
        }

        if (!Enum.TryParse<Models.PowerActionType>(args.Action, true, out var action))
        {
            Console.Error.WriteLine($"错误: 未知的操作类型 '{args.Action}'");
            Console.Error.WriteLine("可用操作: shutdown, restart, logoff, sleep, hibernate");
            return 1;
        }

        if (action == Models.PowerActionType.Sleep || action == Models.PowerActionType.Hibernate)
        {
            Console.WriteLine($"将在 {TimeParser.FormatChinese(seconds)} 后执行 {action.ToDisplayName()}...");
            Thread.Sleep(seconds * 1000);
            power.ExecuteNow(action, args.Force);
        }
        else
        {
            power.ScheduleAction(action, seconds, args.Force);
            var target = DateTime.Now.AddSeconds(seconds);
            Console.WriteLine($"✔ 已计划 {action.ToDisplayName()} — {TimeParser.FormatChinese(seconds)} 后执行");
            Console.WriteLine($"  预计时间: {target:yyyy-MM-dd HH:mm:ss}");
            Console.WriteLine($"  取消命令: DotShutdown --cli --cancel");
        }

        return 0;
    }
}
