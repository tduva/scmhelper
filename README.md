# scmhelper

This is a Ressource for MTA:SA (https://mtasa.com/) to visualize some opcodes from the game's decompiled main.scm.

## Installation

Put the contents of this repository into a subfolder called "scmhelper" in your resources folder, for example `C:\Program Files (x86)\MTA San Andreas 1.5\server\mods\deathmatch\resources\scmhelper`.

## Usage

The most convenient usage is probably through the Map Editor, since it already provides ways to move around and stuff. Start the Map Editor and then enter the following two commands into the console (F8):

    start scmhelper
    showcol

The first command starts the resource, the second command makes the collision shapes visible that this resource uses to visualize stuff.

Once started, you can press F4 or Q to toggle the resource's window. Copy&paste a mission script into the text box on the "Code" tab and click the Parse button to find any opcodes that the resource supports. You can then show a visualization of those opcodes on the "List" tab. The "Settings/Help" tab provides some settings and further information which you should read.

## Notes

* For opcodes and parameters to be parsed correctly the mission script has to be in an expected format, although it seems that the decompiled script that is commonly available should work for this.
* Make sure to not only rely on what this resource shows. Always try to see if there are other triggers or requirements in the actual script that this resource may not be able to visualize.
* Supported opcodes are always shown in the list, even if they can't be visualized, for example if variables are used for the coordinates.

## Known Issues

* After using "G" to go to a shown colshape and then closing the window, the camera will be pointing in a different direction. This is because the "freecam" resource doesn't support setting a camera target.
