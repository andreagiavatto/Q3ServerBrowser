//
//  AGQ3Coordinator.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//
//

#import <Foundation/Foundation.h>
#import "AGCoordinatorDelegate.h"
#import "AGCoordinatorProtocol.h"
#import "AGGame.h"
#import "AGServerPlayerProtocol.h"

@interface AGQ3Coordinator : NSObject <AGCoordinatorProtocol>

@property (nonatomic, strong, readonly) AGGame *game;
@property (nonatomic, weak) id<AGCoordinatorDelegate> delegate;

- (void)refreshServersList;
- (void)statusForServer:(id<AGServerInfoProtocol>)server;

@end
