//
//  AGSQ3erverInfo.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

#import <Foundation/Foundation.h>
#import "AGServerInfoProtocol.h"


FOUNDATION_EXPORT NSString *const kAGQ3ServerInfoHostnameKey;
FOUNDATION_EXPORT NSString *const kAGQ3ServerInfoMapKey;
FOUNDATION_EXPORT NSString *const kAGQ3ServerInfoMaxPlayersKey;
FOUNDATION_EXPORT NSString *const kAGQ3ServerInfoCurrentPlayersKey;
FOUNDATION_EXPORT NSString *const kAGQ3ServerInfoPingKey;
FOUNDATION_EXPORT NSString *const kAGQ3ServerInfoIpKey;
FOUNDATION_EXPORT NSString *const kAGQ3ServerInfoModKey;
FOUNDATION_EXPORT NSString *const kAGQ3ServerInfoGametypeKey;


@interface AGQ3ServerInfo : NSObject <AGServerInfoProtocol>

@property (nonatomic, copy) NSString *ping;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, copy, readonly) NSString *hostname;
@property (nonatomic, copy, readonly) NSString *map;
@property (nonatomic, copy, readonly) NSString *maxPlayers;
@property (nonatomic, copy, readonly) NSString *currentPlayers;
@property (nonatomic, copy, readonly) NSString *mod;
@property (nonatomic, copy, readonly) NSString *gametype;

- (instancetype)initWithDictionary:(NSDictionary *)serverInfo;

@end
