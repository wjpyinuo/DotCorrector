using System.Diagnostics;
using System.Runtime.InteropServices;

namespace DotShutdown.Services;

/// <summary>
/// Handles all Windows power operations: shutdown, restart, sleep, hibernate, log off.
/// Wraps shutdown.exe and Win32 APIs.
/// </summary>
public partial class PowerService
{
    #region Win32 Imports

    [LibraryImport("powrprof.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static partial bool SetSuspendState(
        [MarshalAs(UnmanagedType.Bool)] bool hibernate,
        [MarshalAs(UnmanagedType.Bool)] bool forceCritical,
        [MarshalAs(UnmanagedType.Bool)] bool disableWakeEvent);

    [LibraryImport("advapi32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static partial bool OpenProcessToken(
        IntPtr processHandle,
        uint desiredAccess,
        out IntPtr tokenHandle);

    [LibraryImport("advapi32.dll", SetLastError = true, StringMarshalling = StringMarshalling.Utf16)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static partial bool LookupPrivilegeValue(
        string? lpSystemName,
        string lpName,
        out LUID lpLuid);

    [LibraryImport("advapi32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static partial bool AdjustTokenPrivileges(
        IntPtr tokenHandle,
        [MarshalAs(UnmanagedType.Bool)] bool disableAllPrivileges,
        ref TOKEN_PRIVILEGES newState,
        uint bufferLength,
        IntPtr previousState,
        IntPtr returnLength);

    [LibraryImport("kernel32.dll")]
    private static partial IntPtr GetCurrentProcess();

    [LibraryImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static partial bool CloseHandle(IntPtr hObject);

    [StructLayout(LayoutKind.Sequential)]
    private struct LUID
    {
        public uint LowPart;
        public int HighPart;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct LUID_AND_ATTRIBUTES
    {
        public LUID Luid;
        public uint Attributes;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct TOKEN_PRIVILEGES
    {
        public uint PrivilegeCount;
        public LUID_AND_ATTRIBUTES Privileges;
    }

    private const uint TOKEN_ADJUST_PRIVILEGES = 0x0020;
    private const uint TOKEN_QUERY = 0x0008;
    private const uint SE_PRIVILEGE_ENABLED = 0x00000002;
    private const string SE_SHUTDOWN_NAME = "SeShutdownPrivilege";

    #endregion

    /// <summary>
    /// Enable shutdown privilege for the current process.
    /// Call once at startup.
    /// </summary>
    public bool EnableShutdownPrivilege()
    {
        try
        {
            if (!OpenProcessToken(GetCurrentProcess(),
                TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, out var tokenHandle))
                return false;

            if (!LookupPrivilegeValue(null, SE_SHUTDOWN_NAME, out var luid))
            {
                CloseHandle(tokenHandle);
                return false;
            }

            var tp = new TOKEN_PRIVILEGES
            {
                PrivilegeCount = 1,
                Privileges = new LUID_AND_ATTRIBUTES
                {
                    Luid = luid,
                    Attributes = SE_PRIVILEGE_ENABLED
                }
            };

            AdjustTokenPrivileges(tokenHandle, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            CloseHandle(tokenHandle);
            return true;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Schedule a shutdown/restart after the specified number of seconds.
    /// </summary>
    public bool ScheduleAction(Models.PowerActionType action, int seconds, bool force = false)
    {
        try
        {
            var args = action switch
            {
                Models.PowerActionType.Shutdown => $"/s /t {seconds}",
                Models.PowerActionType.Restart  => $"/r /t {seconds}",
                _ => null
            };

            if (args == null) return false;

            if (force) args += " /f";

            StartShutdownProcess(args);
            return true;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Execute a power action immediately.
    /// </summary>
    public bool ExecuteNow(Models.PowerActionType action, bool force = false)
    {
        try
        {
            return action switch
            {
                Models.PowerActionType.Shutdown  => RunShutdown("/s", force),
                Models.PowerActionType.Restart   => RunShutdown("/r", force),
                Models.PowerActionType.LogOff    => RunShutdown("/l", force),
                Models.PowerActionType.Sleep     => SetSuspendState(false, force, false),
                Models.PowerActionType.Hibernate => SetSuspendState(true, force, false),
                _ => false
            };
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Cancel a pending shutdown/restart.
    /// </summary>
    public bool CancelPending()
    {
        try
        {
            StartShutdownProcess("/a");
            return true;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Check if there's a pending shutdown scheduled.
    /// Uses tasklist to check for shutdown.exe process (non-destructive).
    /// </summary>
    public bool HasPendingShutdown()
    {
        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = "/c schtasks /query /tn \"AutoShutdown\" 2>nul",
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                WindowStyle = ProcessWindowStyle.Hidden
            };
            var process = Process.Start(psi);
            process?.WaitForExit(3000);
            return process?.ExitCode == 0;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Track whether we have a scheduled shutdown (in-process tracking).
    /// </summary>
    public bool HasScheduledShutdown { get; set; }

    private void StartShutdownProcess(string arguments)
    {
        Process.Start(new ProcessStartInfo
        {
            FileName = "shutdown",
            Arguments = arguments,
            UseShellExecute = false,
            CreateNoWindow = true,
            WindowStyle = ProcessWindowStyle.Hidden
        });
    }

    private bool RunShutdown(string arg, bool force)
    {
        var args = force ? $"{arg} /f" : arg;
        StartShutdownProcess(args);
        return true;
    }
}
