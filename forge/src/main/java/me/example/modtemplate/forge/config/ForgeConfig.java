package me.example.modtemplate.forge.config;

import me.example.modtemplate.common.ModConfig;

import java.util.Collections;
import java.util.List;

/**
 * Forge implementation of {@link ModConfig}.
 * Use Forge's ConfigSpec for real projects.
 */
public class ForgeConfig implements ModConfig {

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public List<String> getDisabledWorlds() {
        return Collections.emptyList();
    }
}
