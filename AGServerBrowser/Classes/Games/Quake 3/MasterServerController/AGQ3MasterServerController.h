//
//  AGQ3MasterController.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//
//

#import <Foundation/Foundation.h>
#import "AGMasterServerControllerProtocol.h"
#import "AGMasterServerControllerDelegate.h"


@interface AGQ3MasterServerController : NSObject <AGMasterServerControllerProtocol>

@property (nonatomic, weak) id<AGMasterServerControllerDelegate> delegate;

- (instancetype)initWithGame:(AGGame *)game;
- (void)startFetchingServersList;

@end
