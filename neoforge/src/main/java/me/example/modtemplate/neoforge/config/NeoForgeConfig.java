package me.example.modtemplate.neoforge.config;

import me.example.modtemplate.common.ModConfig;

import java.util.Collections;
import java.util.List;

/**
 * NeoForge implementation of {@link ModConfig}.
 * Use NeoForge's ModConfigSpec for real projects.
 */
public class NeoForgeConfig implements ModConfig {

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public List<String> getDisabledWorlds() {
        return Collections.emptyList();
    }
}
