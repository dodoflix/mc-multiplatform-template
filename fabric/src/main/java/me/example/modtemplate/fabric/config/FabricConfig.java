package me.example.modtemplate.fabric.config;

import me.example.modtemplate.common.ModConfig;

import java.util.Collections;
import java.util.List;

/**
 * Fabric implementation of {@link ModConfig}.
 * Use Fabric's AutoConfig or a simple properties file for real projects.
 */
public class FabricConfig implements ModConfig {

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public List<String> getDisabledWorlds() {
        return Collections.emptyList();
    }
}
