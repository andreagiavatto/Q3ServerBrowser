//
//  AGQ3ServerPlayer.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/23/14.
//
//

#import <Foundation/Foundation.h>
#import "AGServerPlayerProtocol.h"


@interface AGQ3ServerPlayer : NSObject <AGServerPlayerProtocol>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *ping;
@property (nonatomic, copy, readonly) NSString *score;

- (instancetype)initWithName:(NSString *)name withPing:(NSString *)ping withScore:(NSString *)score;

@end
