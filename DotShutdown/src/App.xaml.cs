using DotShutdown.Services;
using Microsoft.UI.Xaml;

namespace DotShutdown;

public partial class App : Application
{
    private static Mutex? _mutex;
    private Window? _window;

    public static SettingsService Settings { get; private set; } = null!;
    public static PowerService Power { get; private set; } = null!;
    public static CountdownService Countdown { get; private set; } = null!;
    public static NotificationService Notifications { get; private set; } = null!;
    public static TrayService Tray { get; private set; } = null!;

    public App()
    {
        this.InitializeComponent();

        // Single instance check
        _mutex = new Mutex(true, "DotShutdown_SingleInstance_v1", out bool isNewInstance);
        if (!isNewInstance)
        {
            // Another instance is already running - exit process
            Environment.Exit(0);
            return;
        }

        // Initialize services
        Settings = new SettingsService();
        Power = new PowerService();
        Countdown = new CountdownService();
        Notifications = new NotificationService();
        Tray = new TrayService();
    }

    protected override void OnLaunched(LaunchActivatedEventArgs args)
    {
        _window = new MainWindow();
        _window.Activate();

        // Initialize tray after window is created
        Tray.Initialize(_window);
    }

    public static Window? GetMainWindow()
    {
        return (Current as App)?._window;
    }
}
