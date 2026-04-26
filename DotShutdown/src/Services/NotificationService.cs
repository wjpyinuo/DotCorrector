using Microsoft.Windows.AppNotifications;
using Microsoft.Windows.AppNotifications.Builder;

namespace DotShutdown.Services;

/// <summary>
/// Manages Windows Toast notifications and sound alerts.
/// </summary>
public class NotificationService
{
    private bool _initialized;

    public void Initialize()
    {
        if (_initialized) return;

        var notificationManager = AppNotificationManager.Default;
        notificationManager.NotificationInvoked += OnNotificationInvoked;
        notificationManager.Register();
        _initialized = true;
    }

    /// <summary>
    /// Show a notification that a power action has been scheduled.
    /// </summary>
    public void ShowScheduled(string actionName, DateTime targetTime)
    {
        var builder = new AppNotificationBuilder()
            .AddText($"已计划 {actionName}")
            .AddText($"预计执行时间: {targetTime:HH:mm:ss}")
            .AddButton(new AppNotificationButton("取消")
                .AddArgument("action", "cancel"))
            .AddButton(new AppNotificationButton("打开")
                .AddArgument("action", "show"));

        var notification = builder.BuildNotification();
        notification.Expiration = TimeSpan.FromMinutes(5);
        AppNotificationManager.Default.Show(notification);
    }

    /// <summary>
    /// Show a countdown warning notification.
    /// </summary>
    public void ShowCountdownWarning(int minutesLeft, string actionName)
    {
        var builder = new AppNotificationBuilder()
            .AddText($"还有 {minutesLeft} 分钟将执行{actionName}")
            .AddButton(new AppNotificationButton("取消关机")
                .AddArgument("action", "cancel"))
            .AddButton(new AppNotificationButton("延后 10 分钟")
                .AddArgument("action", "snooze"));

        var notification = builder.BuildNotification();
        notification.Expiration = TimeSpan.FromMinutes(2);
        AppNotificationManager.Default.Show(notification);
    }

    /// <summary>
    /// Show a final warning (last N seconds).
    /// </summary>
    public void ShowFinalWarning(int secondsLeft, string actionName)
    {
        var builder = new AppNotificationBuilder()
            .AddText($"⚠ 还有 {secondsLeft} 秒将执行{actionName}！")
            .AddButton(new AppNotificationButton("取消")
                .AddArgument("action", "cancel"));

        var notification = builder.BuildNotification();
        notification.Expiration = TimeSpan.FromSeconds(Math.Max(5, secondsLeft));
        AppNotificationManager.Default.Show(notification);
    }

    /// <summary>
    /// Play a system alert sound.
    /// </summary>
    public void PlayAlertSound()
    {
        try
        {
            System.Media.SystemSounds.Exclamation.Play();
        }
        catch
        {
            // Ignore sound errors
        }
    }

    /// <summary>
    /// Play a beep for final countdown.
    /// </summary>
    public void PlayBeep(int frequency = 1000, int durationMs = 200)
    {
        try
        {
            Console.Beep(frequency, durationMs);
        }
        catch
        {
            // Ignore beep errors
        }
    }

    public void Unregister()
    {
        if (_initialized)
        {
            AppNotificationManager.Default.Unregister();
            _initialized = false;
        }
    }

    private void OnNotificationInvoked(AppNotificationManager sender, AppNotificationActivatedEventArgs args)
    {
        if (args.Arguments.TryGetValue("action", out var action))
        {
            switch (action)
            {
                case "cancel":
                    App.Countdown.Stop();
                    App.Power.CancelPending();
                    break;
                case "snooze":
                    App.Countdown.Stop();
                    App.Power.CancelPending();
                    App.Countdown.Start(
                        App.Countdown.CurrentTask?.Action ?? Models.PowerActionType.Shutdown,
                        600);
                    break;
                case "show":
                    var window = App.GetMainWindow();
                    window?.DispatcherQueue.TryEnqueue(() =>
                    {
                        window?.Activate();
                    });
                    break;
            }
        }
    }
}
