//
//  AGQ3Coordinator.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//
//

#import "AGQ3Coordinator.h"
#import "AGQ3MasterServerController.h"
#import "AGQ3Parser.h"
#import "AGQ3ServerController.h"


@interface AGQ3Coordinator ()
<
AGMasterServerControllerDelegate,
AGServerControllerDelegate,
AGParserDelegate
>

@property (nonatomic, strong, readwrite) AGGame *game;
@property (nonatomic, strong) AGQ3MasterServerController *masterServerController;
@property (nonatomic, strong) AGQ3ServerController *serverController;
@property (nonatomic, strong) AGQ3Parser *q3parser;

@end

@implementation AGQ3Coordinator

- (instancetype)init
{
	self = [super init];
	if (self) {
		_masterServerController = [[AGQ3MasterServerController alloc] initWithGame:self.game];
		_masterServerController.delegate = self;
		
		_serverController = [[AGQ3ServerController alloc] init];
		_serverController.delegate = self;
	}
	
	return self;
}


#pragma mark - Getters

- (AGGame *)game
{
	if (!_game) {
		_game = [[AGGame alloc] initWithDictionary:@{
													 kAGGameTitleKey : @"Quake 3 Arena",
													 kAGGameMasterServerAddressKey : @"master.ioquake3.org",
													 kAGGameMasterServerPort : @"27950"
													 }];
	}
	
	return _game;
}

- (AGQ3Parser *)q3parser
{
	if (!_q3parser) {
		_q3parser = [[AGQ3Parser alloc] init];
		_q3parser.delegate = self;
	}
	
	return _q3parser;
}


#pragma mark - Public metods

- (void)refreshServersList
{
	DLog(@"Game: %@ refreshing list from master server %@:%@", self.game.title, self.game.masterServerAddress, self.game.masterServerPort);
	[self.serverController clearPreviousPendingRequests];
	[self.masterServerController startFetchingServersList];
}

- (void)statusForServer:(id<AGServerInfoProtocol>)server
{
	NSArray *addressComponents = [server.ip componentsSeparatedByString:@":"];
	if (addressComponents.count == 2) {
		[self.serverController statusForServerWithIp:addressComponents[0] andPort:addressComponents[1]];
	}
}


#pragma mark - AGMasterServerControllerDelegate

- (void)masterController:(id<AGMasterServerControllerProtocol>)controller didFinishFetchingServersWithOperation:(AGServerOperation *)operation
{
	[self.q3parser parseServersWithData:operation.responseData];
}

#pragma mark - AGServerControllerDelegate

- (void)serverController:(id<AGServerControllerProtocol>)controller didFinishFetchingServerInfoWithOperation:(AGServerOperation *)operation
{
	[self.q3parser parseServerInfoWithData:operation.responseData andOperation:operation];
}

- (void)serverController:(id<AGServerControllerProtocol>)controller didFinishFetchingServerStatusWithOperation:(AGServerOperation *)operation
{
	[self.q3parser parseServerStatusWithData:operation.responseData andOperation:operation];
}


#pragma mark - AGParserDelegate

- (void)didFinishParsingServersDataForParser:(id<AGParserProtocol>)parser withServers:(NSArray *)servers
{
	DLog(@"Fetched servers: %@", servers);
	for (NSString *ip in servers) {
		NSArray *address = [ip componentsSeparatedByString:@":"];
		if (address.count == 2) {
			[self.serverController infoForServerWithIp:address[0] andPort:address[1]];
		}
	}
}

- (void)didFinishParsingServerInfoDataForParser:(id<AGParserProtocol>)parser withServerInfo:(id<AGServerInfoProtocol>)serverInfo
{
	if (serverInfo) {
		DLog(@"Fetched info for server: %@ >> %@", serverInfo.ip, serverInfo);
		[self.delegate didFinishFetchingInfoForServer:serverInfo];
	}
}

- (void)didFinishParsingServerStatusDataForParser:(id<AGParserProtocol>)parser withServerStatus:(NSDictionary *)serverStatus
{
	if (serverStatus) {
		DLog(@"Fetched status for selected server: %@", serverStatus);
		[self.delegate didFinishFetchingStatusForServer:serverStatus];
	}
}

- (void)didFinishParsingServerPlayersForParser:(id<AGParserProtocol>)parser withPlayers:(NSArray *)players
{
	if (players) {
		DLog(@"Fetched players for selected server: %@", players);
		[self.delegate didFinishFetchingPlayersForServer:players];
	}
}


@end
