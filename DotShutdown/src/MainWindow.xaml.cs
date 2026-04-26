using DotShutdown.Models;
using DotShutdown.ViewModels;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using WinRT.Interop;

namespace DotShutdown;

public sealed partial class MainWindow : Window
{
    public TimerViewModel Vm { get; }
    private readonly AppWindow _appWindow;

    public MainWindow()
    {
        this.InitializeComponent();

        var hwnd = WindowNative.GetWindowHandle(this);
        var windowId = Win32Interop.GetWindowIdFromWindow(hwnd);
        _appWindow = AppWindow.GetAppWindowById(windowId);
        _appWindow.Title = "DotShutdown";

        Vm = new TimerViewModel(
            App.Countdown,
            App.Power,
            App.Settings,
            App.Notifications);

        ApplyTheme(App.Settings.Current.Theme);
        this.Closed += OnWindowClosed;
        App.Power.EnableShutdownPrivilege();
        App.Notifications.Initialize();
        AppWindow.Resize(new Windows.Graphics.SizeInt32(520, 680));
    }

    private void OnActionClick(object sender, RoutedEventArgs e)
    {
        if (sender is Button btn && btn.Tag is string tag)
            Vm.SetActionCommand.Execute(tag);
    }

    private void OnPresetClick(object sender, RoutedEventArgs e)
    {
        if (sender is Button btn && btn.Tag is string tag && int.TryParse(tag, out int minutes))
        {
            Vm.SetPresetCommand.Execute(minutes);
            InputHourBox.Text = (minutes / 60).ToString();
            InputMinBox.Text = (minutes % 60).ToString();
            InputSecBox.Text = "0";
        }
    }

    private void OnInputChanged(object sender, RoutedEventArgs e)
    {
        int.TryParse(InputHourBox?.Text ?? "0", out int h);
        int.TryParse(InputMinBox?.Text ?? "0", out int m);
        int.TryParse(InputSecBox?.Text ?? "0", out int s);
        Vm.OnInputChanged(h, m, s);
    }

    private async void OnStartClick(object sender, RoutedEventArgs e)
    {
        if (Vm.IsRunning) return;

        int totalSeconds = Vm.GetTotalSeconds();
        if (totalSeconds <= 0)
        {
            var err = new ContentDialog
            {
                Title = "时间无效",
                Content = "请设置一个大于 0 的时间。",
                CloseButtonText = "确定",
                XamlRoot = this.Content.XamlRoot
            };
            await err.ShowAsync();
            return;
        }

        if (Vm.ConfirmBeforeAction)
        {
            var targetTime = DateTime.Now.AddSeconds(totalSeconds);
            var dialog = new ContentDialog
            {
                Title = "确认操作",
                Content = $"操作：{Vm.SelectedAction.ToDisplayName()}\n" +
                          $"倒计时：{Helpers.TimeParser.FormatHMS(totalSeconds)}\n" +
                          $"预计时间：{targetTime:HH:mm:ss}",
                PrimaryButtonText = "确定",
                CloseButtonText = "取消",
                DefaultButton = ContentDialogButton.Primary,
                XamlRoot = this.Content.XamlRoot
            };
            if (await dialog.ShowAsync() != ContentDialogResult.Primary) return;
        }

        Vm.StartCountdownCommand.Execute(null);
    }

    private void OnCancelClick(object sender, RoutedEventArgs e)
    {
        Vm.CancelCountdownCommand.Execute(null);
    }

    private void OnTrayShowWindow(object sender, RoutedEventArgs e) => this.Activate();

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

    private void OnWindowClosed(object sender, WindowEventArgs args)
    {
        if (Vm.MinimizeToTray)
        {
            args.Handled = true;
            var hwnd = WindowNative.GetWindowHandle(this);
            NativeMethods.ShowWindow(hwnd, NativeMethods.SW_HIDE);
        }
    }

    private void ApplyTheme(string theme)
    {
        if (this.Content is FrameworkElement root)
        {
            root.RequestedTheme = theme switch
            {
                "Dark" => ElementTheme.Dark,
                "Light" => ElementTheme.Light,
                _ => ElementTheme.Default
            };
        }
    }
}
