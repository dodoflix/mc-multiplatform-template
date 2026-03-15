package me.example.modtemplate.bukkit;

import me.example.modtemplate.bukkit.config.BukkitConfig;
import me.example.modtemplate.bukkit.listeners.ExampleListener;
import org.bukkit.plugin.java.JavaPlugin;

/**
 * Main entry point for the ModTemplate Bukkit/Spigot/Paper plugin.
 */
public final class ModTemplate extends JavaPlugin {

    private static ModTemplate instance;

    @Override
    public void onEnable() {
        instance = this;

        saveDefaultConfig();
        BukkitConfig config = new BukkitConfig(getConfig());

        getServer().getPluginManager().registerEvents(new ExampleListener(config), this);

        getLogger().info("ModTemplate enabled!");
    }

    @Override
    public void onDisable() {
        getLogger().info("ModTemplate disabled.");
    }

    /**
     * Returns the singleton plugin instance.
     *
     * @return the plugin instance
     */
    public static ModTemplate getInstance() {
        return instance;
    }
}
