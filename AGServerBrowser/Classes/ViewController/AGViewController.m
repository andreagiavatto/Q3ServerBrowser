//
//  AGViewController.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//


#import "AGViewController.h"
#import "AGQ3Coordinator.h"

@interface AGViewController () <NSTableViewDelegate, NSTableViewDataSource, AGCoordinatorDelegate>

@property (nonatomic, strong) id<AGCoordinatorProtocol> coordinator;

@property (nonatomic, strong) NSMutableArray *servers;
@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) NSDictionary *status;

@property (nonatomic, assign) NSInteger selectedServerIndex;

@end


@implementation AGViewController

- (BOOL)windowShouldClose:(id)sender
{
    [NSApp terminate:nil];
    return YES;
}

- (void)awakeFromNib
{
	// -- Init data sources
	self.servers = [NSMutableArray array];
	self.players = [NSArray array];
	self.status = [NSDictionary dictionary];

	// -- Init label
	[self.numOfServersFound setStringValue:NSLocalizedString(@"EmptyServersList", nil)];
}


#pragma mark - Getters

- (AGQ3Coordinator *)coordinator
{
	if (!_coordinator) {
		_coordinator = [[AGQ3Coordinator alloc] init];
		_coordinator.delegate = self;
	}
	
	return _coordinator;
}


#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (aTableView == self.serversTableView) {
		return [self.servers count];
	}
	if (aTableView == self.statusTableView) {
		return [[self.status allKeys] count];
	}
	if (aTableView == self.playersTableView) {
		return [self.players count];
	}
	return 0;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (aTableView == self.serversTableView) {
		id<AGServerInfoProtocol> server = [self.servers objectAtIndex:rowIndex];
		if ([[aTableColumn identifier] isEqualToString:@"players"]) {
			return [NSString stringWithFormat:@"%@ / %@", server.currentPlayers, server.maxPlayers];
		} else {
			SEL getter = NSSelectorFromString([aTableColumn identifier]);
			if ([server respondsToSelector:getter]) {
				return [server performSelector:getter];
			}
		}
	}
	if (aTableView == self.statusTableView) {
		NSArray *keys = [self.status allKeys];
		NSString *setting = [keys objectAtIndex:rowIndex];
		if ([[aTableColumn identifier] isEqualToString:@"Setting"]) {
			return setting;
		} else {
			return [self.status objectForKey:setting];
		}
	}
	if (aTableView == self.playersTableView) {
		id<AGServerPlayerProtocol> player = [self.players objectAtIndex:rowIndex];
		SEL getter = NSSelectorFromString([aTableColumn identifier]);
		if ([player respondsToSelector:getter]) {
			return [player performSelector:getter];
		}
	}
	return @"";
}
#pragma clang diagnostic pop


#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if (aTableView == self.serversTableView) {
		id<AGServerInfoProtocol> server = [self.servers objectAtIndex:rowIndex];
		NSNumber *ping = [NSNumber numberWithInteger:[server.ping integerValue]];
		
		if ([[aTableColumn identifier] isEqualToString:@"ping"]) {
			if ([ping compare:@60] == NSOrderedAscending) {
				[aCell setTextColor:kMGTGoodPingColor];
			} else {
				if ([ping compare:@100] == NSOrderedAscending) {
					[aCell setTextColor:kMGTAveragePingColor];
				} else {
					[aCell setTextColor:kMGTBadPingColor];
				}
			}
		}
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSTableView *tableView = (NSTableView *)[aNotification object];
	if (tableView == self.serversTableView) {
		NSInteger selectedRow = [self.serversTableView selectedRow];
		if (selectedRow < self.servers.count) {
			self.status = [NSDictionary dictionary];
			self.players = [NSArray array];
			[self.statusTableView reloadData];
			[self.playersTableView reloadData];
			id<AGServerInfoProtocol> server = [self.servers objectAtIndex:selectedRow];
			[self.coordinator statusForServer:server];
		}
	}
}

//- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
//{
//	if (tableView == self.serversTableView) {
//		NSArray *newDescriptors = [tableView sortDescriptors];
//		[self.servers sortedArrayUsingDescriptors:newDescriptors];
//		[self.serversTableView reloadData];
//	}
//}


#pragma mark - Public methods

- (IBAction)refreshServersList:(id)sender
{
	[self p_clearDataSource];
	[self p_reloadDataSource];
	
	[self.coordinator refreshServersList];
	[self.loadingIndicator startAnimation:self];
}


#pragma mark - AGCoordinatorDelegate

- (void)didFinishFetchingInfoForServer:(id<AGServerInfoProtocol>)serverInfo
{
	if (serverInfo) {
		[self.servers addObject:serverInfo];
		dispatch_async(dispatch_get_main_queue(), ^(){
			[self.loadingIndicator stopAnimation:self];
			[self.numOfServersFound setStringValue:[NSString stringWithFormat:@"%lu servers found.", (unsigned long)self.servers.count]];
			[self.serversTableView reloadData];
		});
	}
}

- (void)didFinishFetchingStatusForServer:(NSDictionary *)serverStatus
{
	if (serverStatus) {
		self.status = serverStatus;
		dispatch_async(dispatch_get_main_queue(), ^(){
			[self.statusTableView reloadData];
		});
	}
}

- (void)didFinishFetchingPlayersForServer:(NSArray *)serverPlayers
{
	if (serverPlayers) {
		self.players = serverPlayers;
		dispatch_async(dispatch_get_main_queue(), ^(){
			[self.playersTableView reloadData];
		});
	}
}


#pragma mark - Private methods

- (void)p_clearDataSource
{
	[self.servers removeAllObjects];
	self.players = [NSArray array];
	self.status = [NSDictionary dictionary];
}

- (void)p_reloadDataSource
{
	[self.serversTableView reloadData];
	[self.statusTableView reloadData];
	[self.playersTableView reloadData];
}


@end
