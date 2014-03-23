//
//  AGGame.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 11/16/13.
//
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString *const kAGGameTitleKey;
FOUNDATION_EXPORT NSString *const kAGGameMasterServerAddressKey;
FOUNDATION_EXPORT NSString *const kAGGameMasterServerPort;


@interface AGGame : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *masterServerAddress;
@property (nonatomic, copy, readonly) NSString *masterServerPort;

- (instancetype)initWithDictionary:(NSDictionary *)gameInfo;

@end
