//
//  AGCoordinatorProtocol.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

#import <Foundation/Foundation.h>

@protocol AGCoordinatorDelegate;

@protocol AGCoordinatorProtocol <NSObject>

@property (nonatomic, weak) id<AGCoordinatorDelegate> delegate;

- (void)refreshServersList;
- (void)statusForServer:(id<AGServerInfoProtocol>)server;

@end
