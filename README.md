```
__          _______ _____  ______  _____ _   _ ______  _____    
\ \        / /_   _|  __ \|  ____|/ ____| \ | |  ____|/ ____|   
 \ \  /\  / /  | | | |  | | |__  | (___ |  \| | |__  | (___     
  \ \/  \/ /   | | | |  | |  __|  \___ \| . ` |  __|  \___ \    
   \  /\  /   _| |_| |__| | |____ ____) | |\  | |____ ____) |   
    \/  \/   |_____|_____/|______|_____/|_| \_|______|_____/    
                                    by Vitor Vilela & friends
```

Super Mario World Widescreen
============================

![image](https://user-images.githubusercontent.com/12776674/122607515-0e8d4600-d051-11eb-900b-1b072f5bbbad.png)

**Super Mario World Widescreen** is your beloved Mario World
SNES game but in the 16:10, 16:9 or 18:9/2:1 screen aspect ratio.
This is possible by expanding the horizontal resolution by 96/128
pixels, increasing resolution from 256x224 to 352x224 or 384x224.

Since the original SNES does not have this resolution, the emulator
focused into high definition mods **bsnes-hd** must be used.

## Supported screens

Currently SMW Widescreen supports 16:9, 16:10, 2:1/18:9 or 18.5:9 screen
aspect ratios. More aspect ratios are planned and are currently work in
progress, such as 21:9 and 64:27 ultrawide options.

### SMW Widescreen Mode

SMW Widescreen mode expands the screen by 96 pixels (+37.5%), increasing
to 352x224. Can be used on 16:9 mode (with pixel stretch) and
16:10 (without pixel stretch).

### SMW Extrawide Mode

SMW Extrawide mode expands the screen by 128 pixels (+50.0%), increasing
to 384x224. Can be used on 16:9 mode (without pixel stretch) and
2:1/18:9/18.5:9 mode (with pixel streching).

## Instructions

Go to the [Releases](https://github.com/VitorVilela7/wide-snes/releases)
link for the latest download. You will find a zip file with all files needed:
1. The BPS patch, which contains the changes between the original game
and SMW Widescreen.
2. The BSO file (widescreen configuration file), which is used to tell
the emulator how to load the widescreen mode.
3. Preview PNG files, with how Super Mario World looks with a specific
version of the patch. There's version with/without pixel stretching
(par - CRT pixel stretching and raw - no pixel stretching) and
widescreen/extrawide versions for different aspect ratios.

Once you have picked the BPS and BSO files (they must have the same name):
1. [Patch your ROM](https://sneslab.net/wiki/How_to_apply_ROM_patches).
For copyright reasons, the ROM is not provided. You will have to obtain it
on your own.
2. Name the BSO file with the same as your patched ROM file, for
example `SMW.bso` and `SMW.smc`
3. Remove the `.bps` file from the folder you're loading the ROM from,
otherwise you'll get an error from the emulator.
5. [Play with bsnes-hd](https://github.com/DerKoun/bsnes-hd/releases).
You **must** play with bsnes-hd, it won't work on other emulators.
If using RetroArch, simply look for the `bsnes-hd beta` core.

Alternatively, if you just want to play the 16:9 version with CRT pixel
stretching and wanna download the files individually:

1. [Download the latest patch (BPS)](./../../raw/master/smw-widescreen.bps)
2. [Patch your ROM](https://sneslab.net/wiki/How_to_apply_ROM_patches). For copyright reasons, the ROM is not provided. You will have to obtain it on your own.
3. [Download widescreen configuration file (BSO)](./../../raw/master/smw-widescreen.bso) and name it the same as your patched ROM file e.g. `SMW.bso` and `SMW.smc`
4. Remove the `.bps` file from the folder you're loading the ROM from, otherwise you'll get an error from the emulator.
5. [Play with bsnes-hd](https://github.com/DerKoun/bsnes-hd/releases). You **must** play with bsnes-hd, it won't work on other emulators. If using RetroArch, simply look for the `bsnes-hd beta` core.

## Important

- In case you can't get the BSO file working, you can open it using a text editor and manually apply the widescreen settings on bsnes-hd settings.

# Download
Patch version: 1.2

[Download latest patch (BPS)](./../../raw/master/smw-widescreen.bps)

[Download widescreen configuration file (BSO)](./../../raw/master/smw-widescreen.bso)

# Credits
Thank you for the following people that helped me directly, either by
testing, providing technical support or base assembly (patches) files for Super Mario World:
 - MarioE (additional ASM patches)
 - Tattletale (additional ASM patches)
 - LX5 (additional ASM patches)
 - Thomas (additional ASM patches)
 - RussianMan (additional ASM patches)
 - Romi (additional ASM patches)
 - FuSoYa (additional ASM patches, Lunar Magic, technical support)
 - Smallhacker (additional ASM patches)
 - Alcaro (additional ASM patches)
 - JamesD28 (additional ASM patches)
 - Mattrizzle (additional ASM patches)
 - JackTheSpades (additional ASM patches)
 - HammerBrother (additional ASM patches)
 - Arujus (additional ASM patches, SA-1 Pack)
 - Near (technical support, convincing me to do the patch!)
 - DerKoun (technical support, convincing me to do the patch!)
 - Adam Londero (testing and bugs report)
 - RupeeClock (testing and bugs report)
 - z384 (testing and bugs report)
 - FuRiOUS (testing and bugs report)
 - Seathorne (testing)
 - Doctor No (testing)
 - Rugar (testing)
 - danielah05 (bugs report)

Special thanks also for all my patrons from
https://www.patreon.com/vitorvilela, specially for:

* Christopher
* Devon Shaw
* Evan Clue
* Fabio Akita
* Frogamus Lewd
* gunmakuma
* Jake Mauer
* Josh Tarie
* kccheng
* Luke Greatwow
* NeGiZON
* PsychoFox
* sam

# Contact
You can contact me though the following links:

* My Twitter profile: https://twitter.com/HackerVilela
* My Instagram profile: https://instagram.com/hackervilela
* My Patreon profile: https://www.patreon.com/vitorvilela
* My Github profile: https://github.com/VitorVilela7
* My Website: https://www.sneslab.net/

