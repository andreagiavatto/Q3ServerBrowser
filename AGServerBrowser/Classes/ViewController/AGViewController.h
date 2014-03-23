//
//  AGViewController.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AGViewController : NSObject

@property (nonatomic, weak) IBOutlet NSTableView *serversTableView;
@property (nonatomic, weak) IBOutlet NSTableView *statusTableView;
@property (nonatomic, weak) IBOutlet NSTableView *playersTableView;

@property (nonatomic, weak) IBOutlet NSToolbarItem *refreshServersItem;

@property (nonatomic, weak) IBOutlet NSProgressIndicator *loadingIndicator;
@property (nonatomic, weak) IBOutlet NSTextField *numOfServersFound;


- (IBAction)refreshServersList:(id)sender;

@end
