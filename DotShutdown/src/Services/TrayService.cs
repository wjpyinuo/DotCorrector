using Microsoft.UI.Xaml;
using H.NotifyIcon;

namespace DotShutdown.Services;

/// <summary>
/// Manages system tray icon and its context menu.
/// Uses H.NotifyIcon.WinUI for reliable tray integration.
/// </summary>
public class TrayService
{
    private TaskbarIcon? _trayIcon;
    private Window? _window;

    public void Initialize(Window window)
    {
        _window = window;
    }

    public void UpdateTooltip(string text)
    {
        if (_trayIcon != null)
            _trayIcon.ToolTipText = text;
    }

    public void ShowWindow()
    {
        _window?.DispatcherQueue.TryEnqueue(() =>
        {
            _window?.Activate();
        });
    }

    public void Dispose()
    {
        _trayIcon?.Dispose();
    }
}

/// <summary>
/// Native method imports for window manipulation.
/// </summary>
internal static partial class NativeMethods
{
    public const int SW_HIDE = 0;
    public const int SW_SHOW = 5;

    [System.Runtime.InteropServices.LibraryImport("user32.dll")]
    [return: System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.Bool)]
    public static partial bool SetForegroundWindow(IntPtr hWnd);

    [System.Runtime.InteropServices.LibraryImport("user32.dll")]
    [return: System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.Bool)]
    public static partial bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
