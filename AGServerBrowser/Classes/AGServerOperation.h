//
//  AGServerOperation.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/18/14.
//
//

#import <Foundation/Foundation.h>

@interface AGServerOperation : NSOperation

- (instancetype)initWithServerIp:(NSString *)ip andPort:(NSString *)port andCommand:(NSData *)command;

@property (nonatomic, copy, readonly) NSString *ip;
@property (nonatomic, assign, readonly) NSUInteger port;
@property (nonatomic, strong, readonly) NSData *command;
@property (nonatomic, strong, readonly) NSData *responseData;
@property (nonatomic, assign, readonly) CFAbsoluteTime executionTime;

@end
