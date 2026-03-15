package me.example.modtemplate.bukkit.config;

import me.example.modtemplate.common.ModConfig;
import org.bukkit.configuration.file.FileConfiguration;

import java.util.Collections;
import java.util.List;

/**
 * Bukkit implementation of {@link ModConfig} backed by {@code config.yml}.
 */
public class BukkitConfig implements ModConfig {

    private final FileConfiguration config;

    /**
     * Creates a new {@link BukkitConfig} wrapping the given Bukkit configuration.
     *
     * @param config the Bukkit {@link FileConfiguration} to read from
     */
    public BukkitConfig(FileConfiguration config) {
        this.config = config;
    }

    @Override
    public boolean isEnabled() {
        return config.getBoolean("enabled", true);
    }

    @Override
    public List<String> getDisabledWorlds() {
        return config.getStringList("disabled-worlds");
    }
}
