//
//  AGServerInfoProtocol.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/19/14.
//
//

#import <Foundation/Foundation.h>

@protocol AGServerInfoProtocol <NSObject>

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
