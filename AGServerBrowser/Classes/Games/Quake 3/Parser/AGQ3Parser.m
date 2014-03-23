//
//  AGQ3Parser.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 12/14/13.
//
//

#import "AGQ3Parser.h"
#import "AGQ3ServerInfo.h"
#import "AGQ3ServerPlayer.h"


@implementation AGQ3Parser

#pragma mark - Public methods

- (void)parseServersWithData:(NSData *)serversData
{
	if (serversData.length) {
		if ([self.delegate respondsToSelector:@selector(willStartParsingResponseDataForParser:)]) {
			[self.delegate willStartParsingServersDataForParser:self];
		}
		
		// -- Remove getServersResponse and EOT from data
		NSData *usefulData = [serversData subdataWithRange:NSMakeRange(23, serversData.length-29)];
		NSUInteger len = usefulData.length;
		
		NSMutableArray *servers = [NSMutableArray array];
		
		for (NSUInteger i = 0; i < len; i++) {
			if (i > 0 && i % 7 == 0) { // -- 4 bytes for ip, 2 for port, 1 separator
				[servers addObject:[self p_parseServerData:[usefulData subdataWithRange:NSMakeRange(i-7, 7)]]];
			}
		}
		
		[self.delegate didFinishParsingServersDataForParser:self withServers:[servers copy]];
	}
}

- (void)parseServerInfoWithData:(NSData *)serverInfoData andOperation:(AGServerOperation *)operation
{
	if (serverInfoData.length) {
		if ([self.delegate respondsToSelector:@selector(willStartParsingServerInfoDataForParser:)]) {
			[self.delegate willStartParsingServerInfoDataForParser:self];
		}
		
		// -- Remove infoResponse and EOT from data
		NSData *usefulData = [serverInfoData subdataWithRange:NSMakeRange(16, serverInfoData.length - 16)];
		NSString *infoResponse = [[NSString alloc] initWithData:usefulData encoding:NSASCIIStringEncoding];
		infoResponse = [infoResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSArray *info = [infoResponse componentsSeparatedByString:@"\\"];
		info = [info filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
		
		NSMutableArray *keys = [NSMutableArray array];
		NSMutableArray *values = [NSMutableArray array];
		[info enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if (idx % 2) {
				[values addObject:obj];
			} else {
				[keys addObject:obj];
			}
		}];
		
		if (keys.count == values.count) {
			NSDictionary *infoD = [NSDictionary dictionaryWithObjects:values forKeys:keys];
			AGQ3ServerInfo *serverInfo = [[AGQ3ServerInfo alloc] initWithDictionary:infoD];
			serverInfo.ping = [NSString stringWithFormat:@"%.0f", round(operation.executionTime*1000)];
			serverInfo.ip = [NSString stringWithFormat:@"%@:%lu", operation.ip, (unsigned long)operation.port];
			[self.delegate didFinishParsingServerInfoDataForParser:self withServerInfo:serverInfo];
		}
	}
}

- (void)parseServerStatusWithData:(NSData *)serverStatusData andOperation:(AGServerOperation *)operation
{
	if (serverStatusData.length) {
		if ([self.delegate respondsToSelector:@selector(willStartParsingServerStatusDataForParser:)]) {
			[self.delegate willStartParsingServerStatusDataForParser:self];
		}
		
		NSData *usefulData = [serverStatusData subdataWithRange:NSMakeRange(20, serverStatusData.length - 20)];
		NSString *statusResponse = [[NSString alloc] initWithData:usefulData encoding:NSASCIIStringEncoding];
		statusResponse = [statusResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		NSArray *statusComponents = [statusResponse componentsSeparatedByString:@"\n"];
		NSString *serverStatus = statusComponents[0];
		
		if (statusComponents.count > 1) {
			// -- We got players
			NSArray *playersStatus = [statusComponents subarrayWithRange:NSMakeRange(1, statusComponents.count-1)];
			[self p_parsePlayersStatus:playersStatus];
		}
		
		NSArray *status = [serverStatus componentsSeparatedByString:@"\\"];
		status = [status filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
		
		NSMutableArray *keys = [NSMutableArray array];
		NSMutableArray *values = [NSMutableArray array];
		[status enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if (idx % 2) {
				[values addObject:obj];
			} else {
				[keys addObject:obj];
			}
		}];
		
		if (keys.count == values.count) {
			NSDictionary *infoD = [NSDictionary dictionaryWithObjects:values forKeys:keys];
			[self.delegate didFinishParsingServerStatusDataForParser:self withServerStatus:infoD];
		}
	}
}


#pragma mark - Private methods

- (NSString *)p_parseServerData:(NSData *)serverData
{
	NSInteger len = serverData.length;
	uint8_t *bytes = (uint8_t *)[serverData bytes];
	int port = 0;
	NSMutableString *server = [[NSMutableString alloc] init];
	for (int i = 0; i < len - 1; i++) {
		if (i < 4) {
			if (i < 3) {
				[server appendFormat:@"%d.", bytes[i]];
			} else {
				[server appendFormat:@"%d", bytes[i]];
			}
		} else {
			if (i == 4) {
				port += bytes[i] << 8;
			} else {
				port += bytes[i];
			}
		}
	}
	
	return [NSString stringWithFormat:@"%@:%d", server, port];
}

- (void)p_parsePlayersStatus:(NSArray *)playersStatus
{
	if (playersStatus.count) {
		NSMutableArray *players = [NSMutableArray array];
		
		if ([self.delegate respondsToSelector:@selector(willStartParsingServerPlayersForParser:)]) {
			[self.delegate willStartParsingServerPlayersForParser:self];
		}
		
		for (NSString *p in playersStatus) {
			NSArray *playerComponents = [p componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if (playerComponents.count == 3) {
				AGQ3ServerPlayer *player = [[AGQ3ServerPlayer alloc] initWithName:playerComponents[2]
																		 withPing:playerComponents[1]
																		withScore:playerComponents[0]];
				if (player) {
					[players addObject:player];
				}
			}
		}
		
		
		if ([self.delegate respondsToSelector:@selector(didFinishParsingServerPlayersForParser:withPlayers:)]) {
			[self.delegate didFinishParsingServerPlayersForParser:self withPlayers:[players copy]];
		}
	}
}

@end
