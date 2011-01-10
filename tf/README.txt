Setup a pug server in 4 easy steps.

1. Download and extract the latest MetaMod Source and SourceMod distributions. You should end up with an "addons" directory. You can find the download url for both packages at:
   - http://www.sourcemm.net/
   - http://www.sourcemod.net/

2. Download and extract the map pack into the "maps" directory. You can find the map pack here (or download the maps individually):
   - http://stats.tf2pug.eoreality.net/maps/
   
3. Overwrite some of the files in the "addons" folder by merging in those in the "addons_overwrite" folder.

4. Navigate to the "addons/sourcemod/plugins" folder. Move "disabled/mapchooser.smx", "disabled/nominations.smx", "disabled/rockthevote.smx" into the current directory (this enables them). Move or delete "funcommands.smx", "funvotes.smx", and "nextmap.smx" to the disabled folder.