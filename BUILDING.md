Building from source
====================

This allows to you customize Super Mario World Widescreen with your own settings and also allows
to you edit and build the patch from scratch.

These steps requires a copy of the Super Mario World game, thus it's not possible to create a
CI or any other form of automated building process publically.

# Pre-requisites

1. Original Super Mario World game image, NTSC-US version.
2. A BPS patcher (e.g. FLIPS)
3. Asar

# Base pre-modified image

On the 'base' folder, there are BPS patches with Super Mario World modified with the following
things:

1. SA-1 Pack v1.41 (low power version) is applied.
2. Lunar Magic v3.30 is installed.
3. Edited levels with required changes for running with a certain resolution.

For example, 'smw-352-base.bps' has all level changes required to the game run at
352x224 resolution. This resolution allows for 16:10 and 16:9 widescreen resolutions
(+48 extra pixels).

You can edit the image with Lunar Magic if you would like to modify a certain level,
keeping in mind that the VRAM patch must be disabled in Options.

# Selecting the screen mode in ASM code

In the "asm" folder, open "main.asm" with a text editor. Find "!widetype =" and select the
screen mode that you would like to use:

* !normal - 352x224 - 16:9 and 16:10 resolutions.
* !extra - 384x224 - 16:9 and 2:1 resolutions.
* !ultra - 448x224 - 2:1, 20.5:9, 21:9 and 64:27 resolutions.
* !hyper - 480x224 - 21:9 and 64:27 resolutions.

Keep in mind that !ultra and !hyper settings are currently not fully implemented, both ASM-wise 
and base-ROM wise, these are experimental and incomplete versions.

Apply main.asm using Asar (alternatively, via the do.sh script) to the base ROM you have chosen.

# Setting up BSO

The BSO file tells how bsnes-hd will render the game.

w1s1WXXS2i0o0p0b1B1c1

Change the WXX to:

* W48 - for 352x224 resolution
* W64 - for 384x224 resolution
* W96 - for 448x224 resolution
* W112 - for 480x224 resolution

Change **o0p0** to **o1p1** to turn on overscan and pixel aspect ratio (e.g. 8:7 pixels).
These settings in particular only affect the bsnes-hd core.

Make sure to save the .bso file to the same name as the ROM file.

# Steps

1. Go to base folder and pick the base patch to use.
2. Apply base patch on ROM.
3. Select resolution on main.asm
4. Apply main.asm on ROM.
5. Set up BSO with the resolution and aspect ratio wanted.
6. Make sure both .sfc and .bso have the same file name and verify the game on bsnes-hd.
