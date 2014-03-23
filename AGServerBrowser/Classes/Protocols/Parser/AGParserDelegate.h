//
//  AGParserDelegate.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 1/2/14.
//
//

#import <Foundation/Foundation.h>
#import "AGServerInfoProtocol.h"

@protocol AGParserProtocol;

@protocol AGParserDelegate <NSObject>

- (void)didFinishParsingServersDataForParser:(id<AGParserProtocol>)parser withServers:(NSArray *)servers;
- (void)didFinishParsingServerInfoDataForParser:(id<AGParserProtocol>)parser withServerInfo:(id<AGServerInfoProtocol>)serverInfo;
- (void)didFinishParsingServerStatusDataForParser:(id<AGParserProtocol>)parser withServerStatus:(NSDictionary *)serverStatus;

@optional
- (void)didFinishParsingServerPlayersForParser:(id<AGParserProtocol>)parser withPlayers:(NSArray *)players;

- (void)willStartParsingServersDataForParser:(id<AGParserProtocol>)parser;
- (void)willStartParsingServerInfoDataForParser:(id<AGParserProtocol>)parser;
- (void)willStartParsingServerStatusDataForParser:(id<AGParserProtocol>)parser;
- (void)willStartParsingServerPlayersForParser:(id<AGParserProtocol>)parser;

@end
