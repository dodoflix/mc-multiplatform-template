package me.example.modtemplate.common;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.junit.jupiter.api.extension.ExtendWith;

import java.util.Arrays;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ExampleFeatureTest {

    @Mock
    private ModConfig config;

    private ExampleFeature feature;

    @BeforeEach
    void setUp() {
        feature = new ExampleFeature(config);
    }

    @Nested
    class WhenFeatureIsEnabled {

        @BeforeEach
        void enableFeature() {
            when(config.isEnabled()).thenReturn(true);
            when(config.getDisabledWorlds()).thenReturn(Collections.emptyList());
        }

        @Test
        void shouldActivate_whenNormalPlayer() {
            assertTrue(feature.shouldActivate("world", false));
        }

        @Test
        void shouldNotActivate_whenPlayerHasBypass() {
            assertFalse(feature.shouldActivate("world", true));
        }

        @ParameterizedTest
        @ValueSource(strings = {"creative_world", "test_world"})
        void shouldNotActivate_whenWorldIsDisabled(String world) {
            when(config.getDisabledWorlds()).thenReturn(Arrays.asList("creative_world", "test_world"));
            assertFalse(feature.shouldActivate(world, false));
        }

        @Test
        void shouldActivate_whenWorldIsNotInDisabledList() {
            when(config.getDisabledWorlds()).thenReturn(Arrays.asList("other_world"));
            assertTrue(feature.shouldActivate("world", false));
        }
    }

    @Nested
    class WhenFeatureIsDisabled {

        @BeforeEach
        void disableFeature() {
            when(config.isEnabled()).thenReturn(false);
        }

        @Test
        void shouldNotActivate_ever() {
            assertFalse(feature.shouldActivate("world", false));
        }
    }
}
