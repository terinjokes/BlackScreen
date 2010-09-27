/*
 * Copyright (c) 2010 Terin Stock
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Cocoa/Cocoa.h>

/**
 * main
 *
 * NOTE TO FUTURE SELF (AND/OR OTHER PEOPLE): This application will switch the wallpaper
 * used on all monitors to either a predefined path, or the first argument to this application.
 * This application will save the wallpapers currently in use to be restore in a future run.
 * However, very little checks are being conducted, so please re-run
 * this application *BEFORE* disconnecting or reconfiguring any monitors, as otherwise
 * your wallpapers might not ever get set correctly!
 */
int main(int argc, char *argv[]) {
	/*
	 * Dear Future Self:
	 *
	 * Here be the dragons
	 */
	objc_start_collector_thread(); // We're not in an Apple Event Loop, so let's setup garbage collection with this
	NSString *filename = @"~/Pictures/black.png";
	if (argc > 1) {
		/*
		 * Let's blindly accept whatever the user provides for the first argument.
		 * Remember, the customer is always right.
		 */
		filename = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
	}
	NSArray *screens = [NSScreen screens];
	NSURL *blackURL = [NSURL fileURLWithPath:[filename stringByExpandingTildeInPath]];
	NSFileManager *fm = [NSFileManager defaultManager];	
	NSMutableDictionary *screenWallpapers;
	if ([fm fileExistsAtPath:[@"~/Library/preferences/net.threestrangedays.blackScreen.plist" stringByExpandingTildeInPath]]  == NO) {
		/*
		 * First Run: Preference file doesn't exist yet. Setup a new Dictionary.
		 */
		screenWallpapers = [[NSMutableDictionary alloc] init];
	} else {
		/*
		 * Preference file found, let's load it
		 */
		screenWallpapers = [NSMutableDictionary dictionaryWithContentsOfFile:[@"~/Library/preferences/net.threestrangedays.blackScreen.plist" stringByExpandingTildeInPath]];
	}
	if ([screenWallpapers objectForKey:@"isBlack"] == [NSNumber numberWithBool:YES]) {
		/*
		 * The "isBlack" key in the Dictionary was defined and set true.
		 * This means the application has been ran before, and blacked the wallpapers
		 * We need to restore the user's wallpapers
		 */
		for (NSScreen *screen in screens) {
			NSNumber *screenID = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
			NSString *currentWallpaperString = [screenWallpapers objectForKey:[screenID stringValue]];
			NSURL *currenWallpaper = [NSURL URLWithString:currentWallpaperString];
			[[NSWorkspace sharedWorkspace] setDesktopImageURL:currenWallpaper forScreen:screen options:nil error:nil];
			[screenWallpapers setObject:[NSNumber numberWithBool:NO] forKey:@"isBlack"];
		}
	} else {
		/*
		 * The "isBlack" key is either not defined or false.
		 * We can black the wallpapers.
		 */
		for (NSScreen *screen in screens) {
			NSURL *currentWallpaper = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:screen];
			NSNumber *screenID = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
			[screenWallpapers setObject:[currentWallpaper absoluteString] forKey:[screenID stringValue]];
			NSURL *url = [NSURL fileURLWithPath:[filename stringByExpandingTildeInPath]];
			[[NSWorkspace sharedWorkspace] setDesktopImageURL:url forScreen:screen options:nil error:nil];
		}
		[screenWallpapers setObject:[NSNumber numberWithBool:YES] forKey:@"isBlack"];
	}
	/*
	 * Write out the new Preference file.
	 */
	[screenWallpapers writeToFile:[@"~/Library/preferences/net.threestrangedays.blackScreen.plist" stringByExpandingTildeInPath] atomically:YES];
}