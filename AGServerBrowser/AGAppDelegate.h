//
//  AGAppDelegate.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AGAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *__weak window;
}

@property (weak) IBOutlet NSWindow *window;

@end
