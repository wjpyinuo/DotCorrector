// Program.cs - Entry point with CLI support
using DotShutdown.Helpers;

namespace DotShutdown;

public static class Program
{
    [STAThread]
    static int Main(string[] args)
    {
        // Check for CLI mode
        if (args.Length > 0)
        {
            var cliArgs = CliParser.Parse(args);

            if (cliArgs.ShowHelp)
            {
                CliParser.PrintHelp();
                return 0;
            }

            if (cliArgs.ShowVersion)
            {
                CliParser.PrintVersion();
                return 0;
            }

            if (cliArgs.IsCliMode)
            {
                return CliParser.Execute(cliArgs);
            }
        }

        // GUI mode
        WinRT.ComWrappersSupport.InitializeComWrappers();

        Microsoft.UI.Xaml.Application.Start((p) =>
        {
            var context = new Microsoft.UI.Dispatching.DispatcherQueueSynchronizationContext(
                Microsoft.UI.Dispatching.DispatcherQueue.GetForCurrentThread());
            System.Threading.SynchronizationContext.SetSynchronizationContext(context);
            new App();
        });

        return 0;
    }
}
