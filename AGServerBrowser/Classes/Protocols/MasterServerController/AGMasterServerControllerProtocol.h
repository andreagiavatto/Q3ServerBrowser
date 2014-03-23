//
//  AGMasterServerControllerProtocol.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/14/14.
//
//

#import <Foundation/Foundation.h>
#import "AGGame.h"

@protocol AGMasterServerControllerDelegate;

@protocol AGMasterServerControllerProtocol <NSObject>

@property (nonatomic, weak) id<AGMasterServerControllerDelegate> delegate;

- (instancetype)initWithGame:(AGGame *)game;
- (void)startFetchingServersList;

@end
