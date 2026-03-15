package me.example.modtemplate.forge.events;

import me.example.modtemplate.common.ExampleFeature;
import me.example.modtemplate.forge.config.ForgeConfig;
import net.minecraftforge.event.entity.player.PlayerEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;

/**
 * Example Forge event handler.
 * Replace this with your actual event handling logic.
 */
@Mod.EventBusSubscriber
public class ExampleHandler {

    private static final ExampleFeature FEATURE = new ExampleFeature(new ForgeConfig());

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
