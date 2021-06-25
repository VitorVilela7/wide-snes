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
SNES game but in the 16:9 resolution. This is possible by expanding
the horizontal resolution by 96 pixels, increasing resolution from
256x224 to 352x224. Since the original SNES does not have this
resolution, the emulator focused into high definition mods **bsnes-hd**
must be used.

## Supported screens

Currently SMW Widescreen supports 16:9 and 16:10 monitor resolutions.
More aspect ratios are planned and are currently work in progress,
namely 2:1 and 21:9 ultrawide aspect ratios.

All aspect ratio has the intended 8:7 pixel aspect ratio from the original
SNES Picture Processing Unit. This means that the screen you will see is
like how would you see on a real TV screen connected to the SNES, except
expanded to the widescreen resolution!

## Instructions

1. [Download the latest patch (BPS)](./../../raw/master/smw-widescreen.bps)
2. [Patch your ROM](https://sneslab.net/wiki/How_to_apply_ROM_patches). For copyright reasons, the ROM is not provided. You will have to obtain it on your own.
3. [Download widescreen configuration file (BSO)](./../../raw/master/smw-widescreen.bso) and name it the same as your patched ROM file e.g. `SMW.bso` and `SMW.smc`
4. Remove the `.bps` file from the folder you're loading the ROM from, otherwise you'll get an error from the emulator.
5. [Play with bsnes-hd](https://github.com/DerKoun/bsnes-hd/releases). You **must** play with bsnes-hd, it won't work on other emulators. If using RetroArch, simply look for the `bsnes-hd beta` core.

Alternatively, you can go to the "Releases" tab and download the most up to date .bps and .bso files on a single zip package.

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
* Fabio Akita
* Frogamus Lewd
* gunmakuma
* Jake Mauer
* Josh Tarie
* kccheng
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

