package me.example.modtemplate.common;

/**
 * Shared constants used across all platforms.
 * Add your own constants here — never hardcode these values in platform code.
 */
public final class Constants {

    /** The mod/plugin ID (must match mod metadata files). */
    public static final String MOD_ID = "modtemplate";

    /** The human-readable display name of the mod/plugin. */
    public static final String MOD_NAME = "ModTemplate";

    /** Permission node that grants full admin access. */
    public static final String PERMISSION_ADMIN = MOD_ID + ".admin";

    private Constants() {}
}
