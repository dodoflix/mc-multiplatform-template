package me.example.modtemplate.common;

import java.util.List;

/**
 * Core business logic for the example feature.
 * Replace this with your actual feature logic.
 * This class has zero platform dependencies — it only uses pure Java.
 */
public class ExampleFeature {

    private final ModConfig config;

    /**
     * Creates a new ExampleFeature backed by the given configuration.
     *
     * @param config the platform-specific configuration implementation
     */
    public ExampleFeature(ModConfig config) {
        this.config = config;
    }

    /**
     * Determines whether the feature should be active in the given world.
     *
     * @param worldName           the name of the world the event occurred in
     * @param hasBypassPermission whether the player holds the bypass permission
     * @return {@code true} if the feature should activate
     */
    public boolean shouldActivate(String worldName, boolean hasBypassPermission) {
        if (!config.isEnabled()) {
            return false;
        }
        if (hasBypassPermission) {
            return false;
        }
        List<String> disabled = config.getDisabledWorlds();
        if (disabled != null && disabled.contains(worldName)) {
            return false;
        }
        return true;
    }
}
