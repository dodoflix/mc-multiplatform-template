package me.example.modtemplate.forge;

import me.example.modtemplate.common.Constants;
import net.minecraftforge.fml.common.Mod;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Main entry point for the ModTemplate Forge mod.
 */
@Mod(Constants.MOD_ID)
public class ModTemplateForge {

    private static final Logger LOGGER = LogManager.getLogger(Constants.MOD_ID);

    public ModTemplateForge() {
        LOGGER.info("{} initialized!", Constants.MOD_NAME);
        // TODO: register event listeners and config here
    }
}
