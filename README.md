# Discord_Updater_Script
I made this little script to fix Discord updates on Linux (that are installed using the native .deb package). 
This is provided as is, use at your own risk, don't run anything you don't understand, and I will NOT be updating this anymore. I'm done with Discord.

###### THE PROBLEM ######
Since I had been using it, the native .deb package on Discord kind of sucks for auto updating. It would get little updates fine, but when a big enough one
came by it wouldn't install without some manual work requiring the intervention of the User. This an auto-update feature does not make, IMHO.

###### THE FIX ######
I found a few things online back when I looked, but I decided to write something my way that fixed it in a way I was happy with. By utilizing the script
with an accompanying desktop launcher, I could launch Discord in one click from my dock like I would the regular app. The launcher calls the script, which
handles checking for and installing updates if there are any, and launching the Discord app.

###### NOTES ######
Basically, I utilized the script by putting it in a directory of my choosing (I was using "\~/Documents/Scripts") and creating a custom
dock launcher placed at "~/.local/share/applications/discord-updater.desktop" that replaced the actual Discord in my dock. It works (at time of writing) on
Ubuntu Desktop 25.10 (the only system I have tested it on) but I expect support would be pretty good across Debian based distros. Take a look at the script
for yourself and make your own adjustments. The code is commented pretty well so I'm not going to explain functionality again here. I specifically designed
it to not run with sudo priveleges.

###### TO USE ######
Copy the script to a folder you have permission to and make sure the script has execute permissions. Create the .desktop item as well, and make sure to update
any paths or naming changes necessary. The Discord (Auto-Update) item will now be available in the Apps menu for you to pin to your Dock or whatever of choice.
