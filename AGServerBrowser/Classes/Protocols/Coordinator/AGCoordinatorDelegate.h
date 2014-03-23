//
//  AGCoordinatorDelegate.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

#import <Foundation/Foundation.h>
#import "AGServerInfoProtocol.h"

@protocol AGCoordinatorDelegate <NSObject>

@required
- (void)didFinishFetchingInfoForServer:(id<AGServerInfoProtocol>)serverInfo;
- (void)didFinishFetchingStatusForServer:(NSDictionary *)serverStatus;
- (void)didFinishFetchingPlayersForServer:(NSArray *)serverPlayers;

@end
