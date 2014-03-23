//
//  AGQ3ServerController.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

#import <Foundation/Foundation.h>
#import "AGServerControllerProtocol.h"
#import "AGServerControllerDelegate.h"

@interface AGQ3ServerController : NSObject <AGServerControllerProtocol>

@property (nonatomic, weak) id<AGServerControllerDelegate> delegate;

- (void)clearPreviousPendingRequests;
- (void)infoForServerWithIp:(NSString *)ip andPort:(NSString *)port;
- (void)statusForServerWithIp:(NSString *)ip andPort:(NSString *)port;

@end
