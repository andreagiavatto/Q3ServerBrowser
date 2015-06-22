//
//  AGServerOperation.m
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/18/14.
//
//

#import "AGServerOperation.h"
#import "AsyncUdpSocket.h"


@interface AGServerOperation () <AsyncUdpSocketDelegate>

@property (nonatomic, strong) AsyncUdpSocket *socket;
@property (nonatomic, assign) CFAbsoluteTime startTime;

@property (nonatomic, copy, readwrite) NSString *ip;
@property (nonatomic, assign, readwrite) NSUInteger port;
@property (nonatomic, strong, readwrite) NSData *command;
@property (nonatomic, strong) NSMutableData *internalResponseData;
@property (nonatomic, assign, readwrite) CFAbsoluteTime executionTime;

@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished)  BOOL finished;

@end

@implementation AGServerOperation

@synthesize executing = _executing, finished = _finished;

NSTimeInterval const kAGDefaultTimeoutInterval = 5.;
NSInteger const kAGDefaultPacketTag = 42;

- (instancetype)initWithServerIp:(NSString *)ip andPort:(NSString *)port andCommand:(NSData *)command
{
	NSAssert(ip, @"ip address is required.");
	NSAssert(port, @"port number is required.");
	NSAssert(command, @"command message is required.");
	
	self = [super init];
	if (self) {
		_ip = [ip copy];
		_port = (unsigned int)[port integerValue];
		_command = command;
		_internalResponseData = [NSMutableData data];
	}
	
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ : %p> %@:%lu -%@- Response data: %@", [self class], self, self.ip, (unsigned long)self.port, self.command, self.responseData];
}


#pragma mark - Getters

- (NSData *)responseData
{
	return [self.internalResponseData copy];
}


#pragma mark - Setters

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}


#pragma mark - Overridden methods

- (void)start
{
	@autoreleasepool {
		if (self.isCancelled) {
			return;
		}
		
		self.executing = YES;
		
		self.socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
		[self.socket receiveWithTimeout:kAGDefaultTimeoutInterval tag:42];
		
		self.startTime = CFAbsoluteTimeGetCurrent();
		
		[self.socket sendData:self.command
					   toHost:self.ip
						 port:self.port
				  withTimeout:kAGDefaultTimeoutInterval
						  tag:kAGDefaultPacketTag];
		
		NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:kAGDefaultTimeoutInterval];
		while(!self.isFinished && [loopUntil timeIntervalSinceNow] > 0) {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
	}
}

- (BOOL)isConcurrent
{
	return YES;
}


#pragma mark - AsyncUdpSocketDelegate

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
	self.executionTime = CFAbsoluteTimeGetCurrent() - self.startTime;
	self.finished = YES;
	[self.internalResponseData appendData:data];
	
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
	self.executionTime = CFAbsoluteTimeGetCurrent() - self.startTime;
	self.finished = YES;
	[self.internalResponseData setLength:0];
}

@end
