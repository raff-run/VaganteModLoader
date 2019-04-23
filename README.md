# VaganteModLoader
Loads mods for Vagante.

# Features
* Resolves conflicts in case two mods try to change the same file
* Updates won't break mods because mods now only need to contain what they changed
* Drastically reduced mod size as you don't need to share the whole data.vra
* Detects if the data.vra was updated, all you need to do if the game updates is run the modLoader again
* Detects if a mod is trying to replace a file that doesn't exist in the original data.vra and ignores it, but notifies you so the modder can remove it from their mod
* Lets you load multiple mods at once with no hassle whatsoever
* Removing mods is just as simple and the original files will come back

# How to use (for players)

1. Download this modloader (from the Releases Page)
1. Extract the VaganteModLoader.zip inside the Vagante folder (where vagante.exe is)
<br>That usually is in \<Your steam library>\steamapps\common\vagante\Mods
1. Place the mod folder inside the Mods folder in the Vagante folder
1. If the Mods folder doesn't exist, create it or run the modLoader once
1. You're done!

For reference, the Mods folder should look like this if you install a mod that changes the bonfire graphics:

Mods\\\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PrettyCoolBonfireMod\\\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;gfx\\\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bonfire.png

To remove mods, just delete the mod folder and run the ModLoader again.

# How to use (for modders)

To create a mod, just drag the original data.vra - That is: data.vra itself if you have no mods or dataBackup.vra if you do, into vagante-extract.

Now get whatever files you need from the folder "data"(or "dataBackup"), change them, then create a folder with your mod's name inside Mods. Now, mimic the folder structure the file you changed was in the extracted data.vra.

For example, this creates a mod that changes the shop song:

1. Extract data.vra using vagante-extract
2. Enter data\sfx
3. Copy shop_theme.ogg
4. Do whatever you want with it or replace it with another song altogether
5. Create a "MyNewShopSongMod" folder inside Mods\\
6. Create a "sfx" folder inside Mods\\MyNewShopSongMod
7. Place your modified shop_theme.ogg inside it
8. Done! Now just run the modloader and test your mod
9. Distribute your mod by uploading MyNewShopSongMod. An easy way to do so is to create a .zip of it and use any host to upload.

# Notes
Here are some things that may explain why your mod looks/sounds weird. These are not problems with the modloader, but with the game itself.
* I'm pretty sure that the game doesn't react well to having any images redimensioned (not sprites, the .png that contains them).
* Modded sounds probably have to have the same length than the original sound, too, but I never tested that. Sounds that are bigger than usual maybe won't be fully played.

# Contributing

If you want to update the ModLoader, create an issue describing what the problem is, fork the repository, then create a pull request after you're done.

If you don't know how programming but still want to help, just create an issue and I'll try to look into it when I have free time.

# Credits
I use and bundle Anybox with this ModLoader. Anybox is a Powershell Module developed by @dm3ll3n (https://github.com/dm3ll3n/AnyBox) that I use to make these popups with custom buttons.