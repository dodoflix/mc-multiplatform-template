package me.example.modtemplate.fabric;

import me.example.modtemplate.common.Constants;
import me.example.modtemplate.common.ExampleFeature;
import me.example.modtemplate.fabric.config.FabricConfig;
import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Main entry point for the ModTemplate Fabric mod.
 */
public class ModTemplateFabric implements ModInitializer {

    public static final Logger LOGGER = LoggerFactory.getLogger(Constants.MOD_ID);

    @Override
    public void onInitialize() {
        FabricConfig config = new FabricConfig();
        ExampleFeature feature = new ExampleFeature(config);

        LOGGER.info("{} initialized!", Constants.MOD_NAME);
        // TODO: register event handlers and features here
    }
}
