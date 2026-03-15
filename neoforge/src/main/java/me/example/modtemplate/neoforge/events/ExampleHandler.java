package me.example.modtemplate.neoforge.events;

import me.example.modtemplate.common.ExampleFeature;
import me.example.modtemplate.neoforge.config.NeoForgeConfig;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.entity.player.PlayerEvent;

import static me.example.modtemplate.common.Constants.MOD_ID;

/**
 * Example NeoForge event handler.
 * Replace this with your actual event handling logic.
 */
@EventBusSubscriber(modid = MOD_ID)
public class ExampleHandler {

    private static final ExampleFeature FEATURE = new ExampleFeature(new NeoForgeConfig());

    /**
     * Example handler — fires when a player logs in.
     *
     * @param event the player login event
     */
    @SubscribeEvent
    public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
        String worldName = event.getEntity().level().dimension().location().getPath();
        boolean hasBypass = event.getEntity().hasPermissions(2);

        if (FEATURE.shouldActivate(worldName, hasBypass)) {
            // TODO: implement your feature logic here
        }
    }
}
