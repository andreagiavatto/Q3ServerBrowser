//
//  AGAppDelegate.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//

#import "AGAppDelegate.h"
#import "Reachability.h"

@implementation AGAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
	
	// Set the blocks
	reach.reachableBlock = ^(Reachability*reach) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kAGServerBrowserReachableKey object:nil];
	};
	
	reach.unreachableBlock = ^(Reachability*reach) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kAGServerBrowserUnreachableKey object:nil];
	};
}

@end
