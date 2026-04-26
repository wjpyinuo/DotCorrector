using DotShutdown.Models;
using DotShutdown.ViewModels;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using WinRT.Interop;

namespace DotShutdown;

/// <summary>
/// Main application window. Handles UI events and delegates logic to TimerViewModel.
/// </summary>
public sealed partial class MainWindow : Window
{
    public TimerViewModel Vm { get; }
    private readonly AppWindow _appWindow;

    public MainWindow()
    {
        this.InitializeComponent();

        // Get AppWindow for title bar customization
        var hwnd = WindowNative.GetWindowHandle(this);
        var windowId = Win32Interop.GetWindowIdFromWindow(hwnd);
        _appWindow = AppWindow.GetAppWindowById(windowId);

        // Set title bar
        _appWindow.Title = "DotShutdown";

        // Set icon if available
        var iconPath = Path.Combine(AppContext.BaseDirectory, "Assets", "app-icon.ico");
        if (File.Exists(iconPath))
            _appWindow.SetIcon(iconPath);

        // Create ViewModel with services
        Vm = new TimerViewModel(
            App.Countdown,
            App.Power,
            App.Settings,
            App.Notifications);

        // Apply theme
        ApplyTheme(App.Settings.Current.Theme);

        // Handle close → minimize to tray
        this.Closed += OnWindowClosed;

        // Enable shutdown privilege
        App.Power.EnableShutdownPrivilege();

        // Initialize notifications
        App.Notifications.Initialize();

        // Set window size
        AppWindow.Resize(new Windows.Graphics.SizeInt32(520, 680));

        // Center on screen
        var displayArea = DisplayArea.GetFromWindowId(windowId, DisplayAreaFallback.Primary);
        if (displayArea != null)
        {
            var centerX = (displayArea.WorkArea.Width - 520) / 2;
            var centerY = (displayArea.WorkArea.Height - 680) / 2;
            AppWindow.Move(new Windows.Graphics.PointInt32(centerX, centerY));
        }
    }

    // ── Action Chip Click ──────────────────────────────

    private void OnActionClick(object sender, RoutedEventArgs e)
    {
        if (sender is Button btn && btn.Tag is string tag)
        {
            Vm.SetActionCommand.Execute(tag);
        }
    }

    // ── Preset Click ───────────────────────────────────

    private void OnPresetClick(object sender, RoutedEventArgs e)
    {
        if (sender is Button btn && btn.Tag is string tag && int.TryParse(tag, out int minutes))
        {
            Vm.SetPresetCommand.Execute(minutes);

            // Sync input boxes
            InputHourBox.Value = minutes / 60;
            InputMinBox.Value = minutes % 60;
            InputSecBox.Value = 0;
        }
    }

    // ── Time Input Changed ─────────────────────────────

    private void OnTimeInputChanged(NumberBox sender, NumberBoxValueChangedEventArgs args)
    {
        Vm.OnInputChanged(
            (int)(InputHourBox?.Value ?? 0),
            (int)(InputMinBox?.Value ?? 0),
            (int)(InputSecBox?.Value ?? 0));
    }

    // ── Start / Cancel ─────────────────────────────────

    private async void OnStartClick(object sender, RoutedEventArgs e)
    {
        if (Vm.IsRunning) return;

        int totalSeconds = Vm.GetTotalSeconds();
        if (totalSeconds <= 0)
        {
            var errDialog = new ContentDialog
            {
                Title = "时间无效",
                Content = "请设置一个大于 0 的时间。",
                CloseButtonText = "确定",
                XamlRoot = this.Content.XamlRoot
            };
            await errDialog.ShowAsync();
            return;
        }

        // Confirmation dialog
        if (Vm.ConfirmBeforeAction)
        {
            var targetTime = DateTime.Now.AddSeconds(totalSeconds);
            var dialog = new ContentDialog
            {
                Title = "确认操作",
                Content = $"操作：{Vm.SelectedAction.ToDisplayName()}\n" +
                          $"倒计时：{Helpers.TimeParser.FormatHMS(totalSeconds)}\n" +
                          $"预计时间：{targetTime:HH:mm:ss}\n\n" +
                          $"点击「确定」开始倒计时。",
                PrimaryButtonText = "确定",
                CloseButtonText = "取消",
                DefaultButton = ContentDialogButton.Primary,
                XamlRoot = this.Content.XamlRoot
            };

            var result = await dialog.ShowAsync();
            if (result != ContentDialogResult.Primary) return;
        }

        // Start countdown (already confirmed)
        Vm.StartCountdownCommand.Execute(null);
    }

    private void OnCancelClick(object sender, RoutedEventArgs e)
    {
        Vm.CancelCountdownCommand.Execute(null);
    }

    // ── Tray Menu ──────────────────────────────────────

    private void OnTrayShowWindow(object sender, RoutedEventArgs e)
    {
        this.Activate();
    }

    private void OnTrayCancel(object sender, RoutedEventArgs e)
    {
        Vm.CancelCountdownCommand.Execute(null);
    }

    private void OnTrayQuit(object sender, RoutedEventArgs e)
    {
        if (Vm.IsRunning)
        {
            App.Power.CancelPending();
            App.Countdown.Stop();
        }
        App.Tray.Dispose();
        App.Current.Exit();
    }

    // ── Window Management ──────────────────────────────

    private void OnWindowClosed(object sender, WindowEventArgs args)
    {
        if (Vm.MinimizeToTray)
        {
            args.Handled = true;
            var hwnd = WindowNative.GetWindowHandle(this);
            NativeMethods.ShowWindow(hwnd, NativeMethods.SW_HIDE);
        }
    }

    // ── Settings / About ───────────────────────────────

    private async void OnSettingsClick(object sender, RoutedEventArgs e)
    {
        var dialog = new ContentDialog
        {
            Title = "设置",
            Content = "设置面板开发中...",
            CloseButtonText = "确定",
            XamlRoot = this.Content.XamlRoot
        };
        await dialog.ShowAsync();
    }

    private async void OnAboutClick(object sender, RoutedEventArgs e)
    {
        var dialog = new ContentDialog
        {
            Title = "关于 DotShutdown",
            Content = "DotShutdown v1.0\n\n" +
                      "专业的 Windows 定时关机工具\n\n" +
                      "支持：关机 / 重启 / 睡眠 / 休眠 / 注销\n\n" +
                      "技术栈：WinUI 3 + .NET 8 + C#",
            CloseButtonText = "确定",
            XamlRoot = this.Content.XamlRoot
        };
        await dialog.ShowAsync();
    }

    // ── Theme ──────────────────────────────────────────

    private void ApplyTheme(string theme)
    {
        if (this.Content is FrameworkElement root)
        {
            root.RequestedTheme = theme switch
            {
                "Dark"  => ElementTheme.Dark,
                "Light" => ElementTheme.Light,
                _       => ElementTheme.Default
            };
        }
    }
}
