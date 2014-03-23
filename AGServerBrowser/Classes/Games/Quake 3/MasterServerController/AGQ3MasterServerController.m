//
//  AGQ3MasterController.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//
//

#import "AGQ3MasterServerController.h"
#import "AGServerOperation.h"


@interface AGQ3MasterServerController ()

@property (nonatomic, strong) AGGame *game;
@property (nonatomic, strong) NSOperationQueue *backgroundQueue;

@end


@implementation AGQ3MasterServerController

- (instancetype)initWithGame:(AGGame *)game
{
	if (!game) {
		return nil;
	}
	
	self = [super init];
	if (self) {
		_game = game;
		_backgroundQueue = [[NSOperationQueue alloc] init];
		_backgroundQueue.maxConcurrentOperationCount = 1;
	}
	
	return self;
}

- (instancetype)init
{
	DLog(@"Use the default initializer initWithGame: instead.");
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}


#pragma mark - Public methods

- (void)startFetchingServersList
{
	const char command[] = {0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x20, 0x36, 0x38, 0x20, 0x65, 0x6d, 0x70, 0x74, 0x79, 0x20, 0x66, 0x75, 0x6c, 0x6c};
	NSData *getServersData = [NSData dataWithBytes:command length:sizeof(command)];

	AGServerOperation *infoOperation = [[AGServerOperation alloc] initWithServerIp:self.game.masterServerAddress
																		   andPort:self.game.masterServerPort
																		andCommand:getServersData];
	typeof(infoOperation) weakOperation __weak = infoOperation;
	infoOperation.completionBlock = ^() {
		typeof(weakOperation) strongOperation __strong = weakOperation;
		if (strongOperation) {
			if ([self.delegate respondsToSelector:@selector(masterController:didFinishFetchingServersWithOperation:)]) {
				[self.delegate masterController:self didFinishFetchingServersWithOperation:strongOperation];
			}
		}
	};
	[self.backgroundQueue addOperation:infoOperation];
}


@end
