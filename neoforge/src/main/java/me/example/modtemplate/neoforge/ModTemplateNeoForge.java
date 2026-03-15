package me.example.modtemplate.neoforge;

import me.example.modtemplate.common.Constants;
import net.neoforged.fml.common.Mod;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Main entry point for the ModTemplate NeoForge mod.
 */
@Mod(Constants.MOD_ID)
public class ModTemplateNeoForge {

    private static final Logger LOGGER = LogManager.getLogger(Constants.MOD_ID);

    public ModTemplateNeoForge() {
        LOGGER.info("{} initialized!", Constants.MOD_NAME);
        // TODO: register event listeners and config here
    }
}
