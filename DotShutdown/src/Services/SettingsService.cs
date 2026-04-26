using System.Text.Json;
using DotShutdown.Models;

namespace DotShutdown.Services;

/// <summary>
/// Manages persistent application settings using JSON file storage.
/// </summary>
public class SettingsService
{
    private static readonly string AppDataDir = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "DotShutdown");

    private static readonly string SettingsPath = Path.Combine(AppDataDir, "settings.json");

    private AppSettings _settings;
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public AppSettings Current => _settings;

    public SettingsService()
    {
        _settings = Load();
    }

    /// <summary>
    /// Load settings from disk, or return defaults.
    /// </summary>
    private AppSettings Load()
    {
        try
        {
            if (File.Exists(SettingsPath))
            {
                var json = File.ReadAllText(SettingsPath);
                return JsonSerializer.Deserialize<AppSettings>(json, JsonOptions) ?? new AppSettings();
            }
        }
        catch
        {
            // If loading fails, return defaults
        }
        return new AppSettings();
    }

    /// <summary>
    /// Save current settings to disk.
    /// </summary>
    public void Save()
    {
        try
        {
            Directory.CreateDirectory(AppDataDir);
            var json = JsonSerializer.Serialize(_settings, JsonOptions);
            File.WriteAllText(SettingsPath, json);
        }
        catch
        {
            // Silently fail on save errors
        }
    }

    /// <summary>
    /// Update a setting and auto-save.
    /// </summary>
    public void Update(Action<AppSettings> modifier)
    {
        modifier(_settings);
        Save();
    }

    /// <summary>
    /// Reset all settings to defaults.
    /// </summary>
    public void Reset()
    {
        _settings = new AppSettings();
        Save();
    }
}
