//
//  AGQ3ServerPlayer.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/23/14.
//
//

#import "AGQ3ServerPlayer.h"


@implementation AGQ3ServerPlayer

- (instancetype)initWithName:(NSString *)name withPing:(NSString *)ping withScore:(NSString *)score
{
	if (!name || !ping || !score) {
		return nil;
	}
	
	self = [super init];
	if (self) {
		_name = name;
		_ping = ping;
		_score = score;
	}
	
	return self;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ : %p> %@ (%@ms) - %@", [self class], self, _name, _ping, _score];
}

@end
