package me.example.modtemplate.bukkit.listeners;

import me.example.modtemplate.bukkit.config.BukkitConfig;
import me.example.modtemplate.common.ExampleFeature;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerJoinEvent;

/**
 * Example Bukkit event listener.
 * Replace this with your actual event handling logic.
 */
public class ExampleListener implements Listener {

    private final ExampleFeature feature;

    /**
     * Creates a new {@link ExampleListener}.
     *
     * @param config the plugin configuration
     */
    public ExampleListener(BukkitConfig config) {
        this.feature = new ExampleFeature(config);
    }

    /**
     * Example handler — fires when a player joins.
     * Replace or remove this as needed.
     *
     * @param event the join event
     */
    @EventHandler
    public void onPlayerJoin(PlayerJoinEvent event) {
        Player player = event.getPlayer();
        boolean hasBypass = player.hasPermission("modtemplate.admin");

        if (feature.shouldActivate(player.getWorld().getName(), hasBypass)) {
            // TODO: implement your feature logic here
        }
    }
}
