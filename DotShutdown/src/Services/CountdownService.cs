using DotShutdown.Models;

namespace DotShutdown.Services;

/// <summary>
/// Manages countdown timer state machine, independent of UI thread.
/// Uses PeriodicTimer for efficient, non-blocking countdown.
/// </summary>
public class CountdownService
{
    private CancellationTokenSource? _cts;
    private Task? _countdownTask;

    /// <summary>Current schedule task, null when idle.</summary>
    public ScheduleTask? CurrentTask { get; private set; }

    /// <summary>Whether a countdown is currently active.</summary>
    public bool IsRunning => CurrentTask?.IsActive == true;

    /// <summary>Fired every second with remaining seconds.</summary>
    public event EventHandler<TimeSpan>? Tick;

    /// <summary>Fired when entering alert threshold (e.g., last 60 seconds).</summary>
    public event EventHandler<int>? Alert;

    /// <summary>Fired when countdown reaches zero.</summary>
    public event EventHandler<PowerActionType>? Completed;

    /// <summary>Fired when countdown is cancelled.</summary>
    public event EventHandler? Cancelled;

    /// <summary>Fired when countdown state changes.</summary>
    public event EventHandler<bool>? RunningStateChanged;

    /// <summary>
    /// Start a countdown for the specified action and duration.
    /// </summary>
    public void Start(PowerActionType action, int totalSeconds, bool forceClose = false)
    {
        // Stop any existing countdown
        Stop();

        CurrentTask = new ScheduleTask
        {
            Action = action,
            ScheduledTime = DateTime.Now.AddSeconds(totalSeconds),
            ForceClose = forceClose,
            IsActive = true
        };

        _cts = new CancellationTokenSource();
        _countdownTask = RunCountdownAsync(_cts.Token);
        RunningStateChanged?.Invoke(this, true);
    }

    /// <summary>
    /// Cancel the current countdown.
    /// </summary>
    public void Stop()
    {
        if (_cts != null)
        {
            _cts.Cancel();
            _cts.Dispose();
            _cts = null;
        }

        if (CurrentTask != null)
        {
            CurrentTask.IsActive = false;
            CurrentTask = null;
        }

        RunningStateChanged?.Invoke(this, false);
    }

    private async Task RunCountdownAsync(CancellationToken ct)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromSeconds(1));

        try
        {
            while (await timer.WaitForNextTickAsync(ct))
            {
                if (CurrentTask == null || !CurrentTask.IsActive)
                    break;

                var remaining = CurrentTask.Remaining;

                if (remaining.TotalSeconds <= 0)
                {
                    // Countdown complete
                    var action = CurrentTask.Action;
                    CurrentTask.IsActive = false;
                    Completed?.Invoke(this, action);
                    break;
                }

                // Fire tick event
                Tick?.Invoke(this, remaining);

                // Fire alert events based on thresholds
                var totalSeconds = (int)remaining.TotalSeconds;
                if (totalSeconds == 60)
                    Alert?.Invoke(this, 60);
                else if (totalSeconds == 30)
                    Alert?.Invoke(this, 30);
                else if (totalSeconds == 10)
                    Alert?.Invoke(this, 10);
                else if (totalSeconds <= 5 && totalSeconds > 0)
                    Alert?.Invoke(this, totalSeconds);
            }
        }
        catch (OperationCanceledException)
        {
            // Expected when stopped
        }
        finally
        {
            if (CurrentTask?.IsActive == true)
            {
                CurrentTask.IsActive = false;
                Cancelled?.Invoke(this, EventArgs.Empty);
            }
        }
    }
}
