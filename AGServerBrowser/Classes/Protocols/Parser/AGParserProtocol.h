//
//  AGParserProtocol.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 12/14/13.
//
//

#import <Foundation/Foundation.h>
#import "AGServerOperation.h"

@protocol AGParserDelegate;

@protocol AGParserProtocol <NSObject>

@property (nonatomic, weak) id<AGParserDelegate> delegate;

- (void)parseServersWithData:(NSData *)serversData;
- (void)parseServerInfoWithData:(NSData *)serverInfoData andOperation:(AGServerOperation *)operation;
- (void)parseServerStatusWithData:(NSData *)serverStatusData andOperation:(AGServerOperation *)operation;

@end
