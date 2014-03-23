//
//  AGMasterControllerDelegate.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/7/14.
//
//

#import <Foundation/Foundation.h>
#import "AGServerOperation.h"

@protocol AGMasterServerControllerProtocol;

@protocol AGMasterServerControllerDelegate <NSObject>

@optional
- (void)didStartFetchingServersForMasterController:(id<AGMasterServerControllerProtocol>)controller;
- (void)masterController:(id<AGMasterServerControllerProtocol>)controller didFinishWithError:(NSError *)error;

@required
- (void)masterController:(id<AGMasterServerControllerProtocol>)controller didFinishFetchingServersWithOperation:(AGServerOperation *)operation;

@end
