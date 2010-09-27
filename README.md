BlackScreen
===========
Setting the wallpaper of all your screens to black (or another custom image), so _you_ don't have to.

Installing
----------
Compile the executable with
    gcc -framework Cocoa -fobjc-gc BlackScreen.m -o BlackScreen

Using
-----
Once you have the executable, you can run it with

    ./BlackScreen

which will use the file `~/Pictures/black.png`. You can pass an optional argument
of the file you would like to use instead:

    ./BlackScreen /Library/Desktop Pictures/Aqua\ Graphite.jpg

If you run the application again, it will restore your original wallpapers. For
best results, run the application before removing or reconfiguring your desktop settings.

License
-------
BlackScreen is released under a MIT license, for more information see COPYING.