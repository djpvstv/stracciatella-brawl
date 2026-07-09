# Fork of Stracciatella Brawl Base to restore Pokémon Trainer

Original Readme.md follows...

# Stracciatella Brawl Base
An example repository for starting to mod Super Smash Brothers Brawl

Stracciatella ice cream (gelato) is vanilla with fine strands of drizzled chocolate. This brawl is not a vanilla brawl, there are some behavioral differences, hence the fine strands of drizzled chocolate.

## How to Use
Download this repository.

Make a modification. For example, create a FitMario.pac and store it in private/wii/app/RSBE/pf/fighter/mario. Change his jumpsquat to 30.

Using VDSync, create a 2GB SD.raw. Move it and replace your existing "sd.raw" on a P+ Netplay dolphin. VSDSync is included.
Set the repository base directory as the "Mods Folder" on the Build Options tab, set a virtual drive, and on the "Dolphin Settins" tab set the "SD Card" path as your P+ Netplay's SD card.

Now hit sync.

Load your game with the included boot.elf in the respository.
This boot.elf is compiled from this project by iGlitch: https://github.com/djpvstv/MinimaLauncherVBrawl

### Tools

Repository comes with VSDSync, the preferred method of syncing your `sd_base` directory with your SD card.
You can also use the `build.bat` or `build.ps1` scripts to automatically build all required gecko codes, then sync.
There is a .vscode directory that allows you to CTRL-SHIFT-B to launch the `build.ps1` task if you are editing this repo in VS Code.

### BrawlInstaller Support

... to do ...
