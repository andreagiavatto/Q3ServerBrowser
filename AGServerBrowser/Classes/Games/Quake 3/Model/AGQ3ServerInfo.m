//
//  AGQ3ServerInfo.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

#import "AGQ3ServerInfo.h"


NSString *const kAGQ3ServerInfoHostnameKey = @"hostname";
NSString *const kAGQ3ServerInfoMapKey = @"mapname";
NSString *const kAGQ3ServerInfoMaxPlayersKey = @"sv_maxclients";
NSString *const kAGQ3ServerInfoCurrentPlayersKey = @"clients";
NSString *const kAGQ3ServerInfoPingKey = @"ping";
NSString *const kAGQ3ServerInfoIpKey = @"ip";
NSString *const kAGQ3ServerInfoModKey = @"game";
NSString *const kAGQ3ServerInfoGametypeKey = @"gametype";


@implementation AGQ3ServerInfo

- (instancetype)initWithDictionary:(NSDictionary *)serverInfo
{
	if (!serverInfo) {
		return nil;
	}
	
	self = [super init];
	if (self) {
		_hostname = [serverInfo objectForKey:kAGQ3ServerInfoHostnameKey] ? serverInfo[kAGQ3ServerInfoHostnameKey] : @"";
		_map = [serverInfo objectForKey:kAGQ3ServerInfoMapKey] ? serverInfo[kAGQ3ServerInfoMapKey] : @"";
		_maxPlayers = [serverInfo objectForKey:kAGQ3ServerInfoMaxPlayersKey] ? serverInfo[kAGQ3ServerInfoMaxPlayersKey] : @"";
		_currentPlayers = [serverInfo objectForKey:kAGQ3ServerInfoCurrentPlayersKey] ? serverInfo[kAGQ3ServerInfoCurrentPlayersKey] : @"";
		_ping = [serverInfo objectForKey:kAGQ3ServerInfoPingKey] ? serverInfo[kAGQ3ServerInfoPingKey] : @"";
		_ip = [serverInfo objectForKey:kAGQ3ServerInfoIpKey] ? serverInfo[kAGQ3ServerInfoIpKey] : @"";
		_mod = [serverInfo objectForKey:kAGQ3ServerInfoModKey] ? serverInfo[kAGQ3ServerInfoModKey] : @"baseq3";
		_gametype = [self p_gametypeForKey:[serverInfo objectForKey:kAGQ3ServerInfoGametypeKey]];
	}
	
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ : %p> %@", [self class], self, @{
																			 @"hostname" : _hostname,
																			 @"ip" : _ip,
																			 @"map" : _map,
																			 @"current players" : _currentPlayers,
																			 @"max players" : _maxPlayers,
																			 @"mod" : _mod,
																			 @"ping" : _ping
																			 }];
}


#pragma mark - Private methods

- (NSString *)p_gametypeForKey:(NSString *)key
{
	NSString *gametype = @"";
	if (key) {
		switch (key.integerValue) {
			case 0:
			case 2:
				gametype = @"ffa";
				break;
				
			case 1:
				gametype = @"tourney";
				break;
				
			case 3:
				gametype = @"tdm";
				break;
				
			case 4:
				gametype = @"ctf";
				break;
				
			default:
				break;
		}
	}
	
	return gametype;
}

@end
