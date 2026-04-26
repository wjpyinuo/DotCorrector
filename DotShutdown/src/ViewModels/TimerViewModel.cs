using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using DotShutdown.Helpers;
using DotShutdown.Models;
using DotShutdown.Services;
using Microsoft.UI.Dispatching;

namespace DotShutdown.ViewModels;

/// <summary>
/// ViewModel for the main timer page. Drives all UI state.
/// Uses CommunityToolkit.Mvvm for source-generated MVVM.
/// </summary>
public partial class TimerViewModel : ObservableObject
{
    private readonly CountdownService _countdown;
    private readonly PowerService _power;
    private readonly SettingsService _settings;
    private readonly NotificationService _notifications;
    private readonly DispatcherQueue _dispatcher;

    // ── Observable Properties ──────────────────────────

    [ObservableProperty]
    private string _timerDisplay = "00:30:00";

    [ObservableProperty]
    private string _statusText = "就绪 — 选择操作和时间";

    [ObservableProperty]
    private string _footerStatus = "⚡ 就绪";

    [ObservableProperty]
    private string _buttonLabel = "▶  开始倒计时";

    [ObservableProperty]
    private bool _isRunning;

    [ObservableProperty]
    private bool _isIdle = true;

    [ObservableProperty]
    private int _inputHours;

    [ObservableProperty]
    private int _inputMinutes = 30;

    [ObservableProperty]
    private int _inputSeconds;

    [ObservableProperty]
    private PowerActionType _selectedAction = PowerActionType.Shutdown;

    // ── Timer Display Segments ─────────────────────────

    [ObservableProperty]
    private string _hours = "00";

    [ObservableProperty]
    private string _minutes = "30";

    [ObservableProperty]
    private string _seconds = "00";

    // ── Timer State Colors ─────────────────────────────

    [ObservableProperty]
    private string _timerColorState = "Normal"; // Normal / Warning / Danger

    // ── Options ────────────────────────────────────────

    [ObservableProperty]
    private bool _forceClose;

    [ObservableProperty]
    private bool _soundAlert = true;

    [ObservableProperty]
    private bool _confirmBeforeAction = true;

    [ObservableProperty]
    private bool _minimizeToTray = true;

    // ── Preset Selection ───────────────────────────────

    [ObservableProperty]
    private int _selectedPresetMinutes = 30;

    // ── Action Chips ───────────────────────────────────

    public bool IsShutdownSelected => SelectedAction == PowerActionType.Shutdown;
    public bool IsRestartSelected  => SelectedAction == PowerActionType.Restart;
    public bool IsSleepSelected    => SelectedAction == PowerActionType.Sleep;
    public bool IsHibernateSelected => SelectedAction == PowerActionType.Hibernate;
    public bool IsLogOffSelected   => SelectedAction == PowerActionType.LogOff;

    // ── Constructor ────────────────────────────────────

    public TimerViewModel(
        CountdownService countdown,
        PowerService power,
        SettingsService settings,
        NotificationService notifications)
    {
        _countdown = countdown;
        _power = power;
        _settings = settings;
        _notifications = notifications;
        _dispatcher = DispatcherQueue.GetForCurrentThread();

        // Wire up countdown events
        _countdown.Tick += OnCountdownTick;
        _countdown.Alert += OnCountdownAlert;
        _countdown.Completed += OnCountdownCompleted;
        _countdown.Cancelled += OnCountdownCancelled;
        _countdown.RunningStateChanged += OnRunningStateChanged;

        // Load saved settings
        LoadSettings();
    }

    // ── Commands ───────────────────────────────────────

    /// <summary>
    /// Start the countdown. Called AFTER confirmation dialog in View.
    /// </summary>
    [RelayCommand]
    private void StartCountdown()
    {
        if (IsRunning) return;

        int totalSeconds = InputHours * 3600 + InputMinutes * 60 + InputSeconds;
        if (totalSeconds <= 0)
        {
            StatusText = "⚠ 请设置大于 0 的时间";
            return;
        }

        // Save preferences
        SaveSettings();

        // Schedule via Windows shutdown command
        _power.ScheduleAction(SelectedAction, totalSeconds, ForceClose);
        _power.HasScheduledShutdown = true;

        // Start visual countdown
        _countdown.Start(SelectedAction, totalSeconds, ForceClose);

        // Show notification
        var targetTime = DateTime.Now.AddSeconds(totalSeconds);
        _notifications.ShowScheduled(SelectedAction.ToDisplayName(), targetTime);
    }

    /// <summary>
    /// Cancel the current countdown.
    /// </summary>
    [RelayCommand]
    private void CancelCountdown()
    {
        _power.CancelPending();
        _power.HasScheduledShutdown = false;
        _countdown.Stop();
    }

    /// <summary>
    /// Set action from chip selection.
    /// </summary>
    [RelayCommand]
    private void SetAction(string actionName)
    {
        if (IsRunning) return;

        if (Enum.TryParse<PowerActionType>(actionName, true, out var action))
        {
            SelectedAction = action;
            OnPropertyChanged(nameof(IsShutdownSelected));
            OnPropertyChanged(nameof(IsRestartSelected));
            OnPropertyChanged(nameof(IsSleepSelected));
            OnPropertyChanged(nameof(IsHibernateSelected));
            OnPropertyChanged(nameof(IsLogOffSelected));
        }
    }

    /// <summary>
    /// Set time from preset.
    /// </summary>
    [RelayCommand]
    private void SetPreset(int minutes)
    {
        if (IsRunning) return;

        SelectedPresetMinutes = minutes;
        InputHours = minutes / 60;
        InputMinutes = minutes % 60;
        InputSeconds = 0;
        UpdateTimerDisplay();
    }

    // ── Event Handlers ─────────────────────────────────

    private void OnCountdownTick(object? sender, TimeSpan remaining)
    {
        _dispatcher.TryEnqueue(() =>
        {
            var totalSec = (int)remaining.TotalSeconds;
            TimerDisplay = TimeParser.FormatHMS(totalSec);
            UpdateTimerSegments(totalSec);

            // Update status text
            if (totalSec <= 10)
                StatusText = $"⚠ 不到 {totalSec} 秒！";
            else if (totalSec <= 60)
                StatusText = "⚠ 不到 1 分钟！";
            else
                StatusText = $"⏳ 剩余 {TimeParser.FormatHMS(totalSec)}";

            // Update color state
            if (totalSec <= 30)
                TimerColorState = "Danger";
            else if (totalSec <= 300)
                TimerColorState = "Warning";
            else
                TimerColorState = "Normal";

            // Update footer
            FooterStatus = $"⏰ 已计划 {SelectedAction.ToDisplayName()} — {TimeParser.FormatHMS(totalSec)} 后执行";
        });
    }

    private void OnCountdownAlert(object? sender, int secondsLeft)
    {
        _dispatcher.TryEnqueue(() =>
        {
            if (SoundAlert)
            {
                if (secondsLeft <= 5)
                    _notifications.PlayBeep(1000, 300);
                else if (secondsLeft <= 10)
                    _notifications.PlayBeep(800, 200);
                else
                    _notifications.PlayAlertSound();
            }

            if (secondsLeft == 60)
                _notifications.ShowFinalWarning(60, SelectedAction.ToDisplayName());
            else if (secondsLeft == 30)
                _notifications.ShowFinalWarning(30, SelectedAction.ToDisplayName());
        });
    }

    private void OnCountdownCompleted(object? sender, PowerActionType action)
    {
        _dispatcher.TryEnqueue(() =>
        {
            StatusText = "执行中...";
            FooterStatus = $"⏻ 正在执行{action.ToDisplayName()}...";
            TimerColorState = "Danger";
            TimerDisplay = "00:00:00";

            // Execute the power action
            _power.ExecuteNow(action, ForceClose);
        });
    }

    private void OnCountdownCancelled(object? sender, EventArgs e)
    {
        _dispatcher.TryEnqueue(() =>
        {
            ResetUI();
            StatusText = "已取消 — 就绪";
            FooterStatus = "✖ 已取消计划";
        });
    }

    private void OnRunningStateChanged(object? sender, bool running)
    {
        _dispatcher.TryEnqueue(() =>
        {
            IsRunning = running;
            IsIdle = !running;

            if (running)
                ButtonLabel = $"⏻  {SelectedAction.ToDisplayName()}倒计时中...";
            else
                ButtonLabel = "▶  开始倒计时";
        });
    }

    // ── Helpers ────────────────────────────────────────

    private void UpdateTimerDisplay()
    {
        int total = InputHours * 3600 + InputMinutes * 60 + InputSeconds;
        TimerDisplay = TimeParser.FormatHMS(total);
        UpdateTimerSegments(total);
        Hours = InputHours.ToString("D2");
        Minutes = InputMinutes.ToString("D2");
        Seconds = InputSeconds.ToString("D2");
    }

    private void UpdateTimerSegments(int totalSeconds)
    {
        var ts = TimeSpan.FromSeconds(totalSeconds);
        Hours = ((int)ts.TotalHours).ToString("D2");
        Minutes = ts.Minutes.ToString("D2");
        Seconds = ts.Seconds.ToString("D2");
    }

    private void ResetUI()
    {
        IsRunning = false;
        IsIdle = true;
        ButtonLabel = "▶  开始倒计时";
        TimerColorState = "Normal";
        UpdateTimerDisplay();
    }

    private void LoadSettings()
    {
        var s = _settings.Current;
        SelectedAction = s.LastActionType;
        InputHours = s.LastMinutes / 60;
        InputMinutes = s.LastMinutes % 60;
        InputSeconds = 0;
        ForceClose = s.ForceClose;
        SoundAlert = s.SoundAlert;
        ConfirmBeforeAction = s.ConfirmBeforeAction;
        MinimizeToTray = s.MinimizeToTray;
        UpdateTimerDisplay();

        OnPropertyChanged(nameof(IsShutdownSelected));
        OnPropertyChanged(nameof(IsRestartSelected));
        OnPropertyChanged(nameof(IsSleepSelected));
        OnPropertyChanged(nameof(IsHibernateSelected));
        OnPropertyChanged(nameof(IsLogOffSelected));
    }

    private void SaveSettings()
    {
        int totalMinutes = InputHours * 60 + InputMinutes;
        _settings.Update(s =>
        {
            s.LastActionType = SelectedAction;
            s.LastMinutes = totalMinutes;
            s.ForceClose = ForceClose;
            s.SoundAlert = SoundAlert;
            s.ConfirmBeforeAction = ConfirmBeforeAction;
            s.MinimizeToTray = MinimizeToTray;
        });
    }

    // ── Public Methods for View ────────────────────────

    public void OnInputChanged(int hours, int minutes, int seconds)
    {
        if (IsRunning) return;
        InputHours = Math.Max(0, hours);
        InputMinutes = Math.Max(0, Math.Min(59, minutes));
        InputSeconds = Math.Max(0, Math.Min(59, seconds));
        UpdateTimerDisplay();
        SelectedPresetMinutes = 0;
    }

    /// <summary>
    /// Get total seconds for current input (used by View for confirmation dialog).
    /// </summary>
    public int GetTotalSeconds()
    {
        return InputHours * 3600 + InputMinutes * 60 + InputSeconds;
    }
}
