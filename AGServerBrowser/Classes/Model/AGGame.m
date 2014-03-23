//
//  AGGame.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 11/16/13.
//
//

#import "AGGame.h"


NSString *const kAGGameTitleKey = @"title";
NSString *const kAGGameMasterServerAddressKey = @"masterServerAddress";
NSString *const kAGGameMasterServerPort = @"masterServerPort";


@interface AGGame ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *masterServerAddress;
@property (nonatomic, copy, readwrite) NSString *serverPort;

@end

@implementation AGGame

- (instancetype)initWithDictionary:(NSDictionary *)gameInfo
{
	self = [super init];
	if (self) {
		[self setValuesForKeysWithDictionary:gameInfo];
	}
	
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ : %p> %@", [self class], self,
			@{
			  @"title" : _title,
			  @"masterServerAddress" : _masterServerAddress,
			  @"masterServerPort" : _masterServerPort
			  }];
}

@end
