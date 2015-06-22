//
//  AGQ3ServerController.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

#import "AGQ3ServerController.h"
#import "AGServerOperation.h"


@interface AGQ3ServerController ()

@property (nonatomic, strong) NSOperationQueue *infoQueue;
@property (nonatomic, strong) NSOperationQueue *statusQueue;

@end

@implementation AGQ3ServerController

NSString *const kAGServerBrowserNotificationReachableKey = @"Reachable";

- (instancetype)init
{
	self = [super init];
	if (self) {
		_infoQueue = [[NSOperationQueue alloc] init];
		_infoQueue.maxConcurrentOperationCount = 5;
		
		_statusQueue = [[NSOperationQueue alloc] init];
		_statusQueue.maxConcurrentOperationCount = 1;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_reachabilityChanged:) name:kAGServerBrowserReachableKey object:@{kAGServerBrowserNotificationReachableKey : @YES}];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_reachabilityChanged:) name:kAGServerBrowserUnreachableKey object:@{kAGServerBrowserNotificationReachableKey : @NO}];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kAGServerBrowserReachableKey object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kAGServerBrowserUnreachableKey object:nil];
}


#pragma mark - Public methods

- (void)clearPreviousPendingRequests
{
	[self.infoQueue cancelAllOperations];
	[self.statusQueue cancelAllOperations];
}

- (void)infoForServerWithIp:(NSString *)ip andPort:(NSString *)port
{
	if (ip.length && port > 0) {
		const char command[] = {0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x69, 0x6e, 0x66, 0x6f, 0x0a};
		NSData *getInfoData = [NSData dataWithBytes:command length:sizeof(command)];

		AGServerOperation *infoOperation = [[AGServerOperation alloc] initWithServerIp:ip
																			   andPort:port
																			andCommand:getInfoData];
		typeof(infoOperation) weakOperation __weak = infoOperation;
		infoOperation.completionBlock = ^() {
			typeof(weakOperation) strongOperation __strong = weakOperation;
			if (strongOperation) {
				if ([self.delegate respondsToSelector:@selector(serverController:didFinishFetchingServerInfoWithOperation:)]) {
					[self.delegate serverController:self didFinishFetchingServerInfoWithOperation:strongOperation];
				}
			}
		};
		[self.infoQueue addOperation:infoOperation];
	}
}

- (void)statusForServerWithIp:(NSString *)ip andPort:(NSString *)port
{
	if (ip.length && port > 0) {
		const char command[] = {0xff, 0xff, 0xff, 0xff, 0x67, 0x65, 0x74, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x0a};
		NSData *getStatusData = [NSData dataWithBytes:command length:sizeof(command)];
		AGServerOperation *infoOperation = [[AGServerOperation alloc] initWithServerIp:ip
																			   andPort:port
																			andCommand:getStatusData];
		typeof(infoOperation) weakOperation __weak = infoOperation;
		infoOperation.completionBlock = ^() {
			typeof(weakOperation) strongOperation __strong = weakOperation;
			if (strongOperation) {
				if ([self.delegate respondsToSelector:@selector(serverController:didFinishFetchingServerStatusWithOperation:)]) {
					[self.delegate serverController:self didFinishFetchingServerStatusWithOperation:strongOperation];
				}
			}
		};
		[self.statusQueue addOperation:infoOperation];
	}
}


#pragma mark - Private methods

- (void)p_reachabilityChanged:(NSNotification *)notification
{
	BOOL isNetworkReachable = [[notification.userInfo objectForKey:kAGServerBrowserNotificationReachableKey] boolValue];
	
	[self.infoQueue setSuspended:!isNetworkReachable];
	[self.statusQueue setSuspended:!isNetworkReachable];
}


@end
