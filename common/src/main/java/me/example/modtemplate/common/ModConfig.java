package me.example.modtemplate.common;

import java.util.List;

/**
 * Platform-agnostic configuration interface.
 * Each platform provides its own implementation backed by its native config system.
 */
public interface ModConfig {

    /**
     * Returns whether the example feature is enabled.
     *
     * @return {@code true} if the feature is active
     */
    boolean isEnabled();

    /**
     * Returns the list of world/dimension names where the feature is disabled.
     *
     * @return list of world names
     */
    List<String> getDisabledWorlds();
}
