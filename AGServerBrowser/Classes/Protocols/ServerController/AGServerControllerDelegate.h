//
//  AGServerControllerDelegate.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

#import <Foundation/Foundation.h>
#import "AGServerOperation.h"

@protocol AGServerControllerProtocol;

@protocol AGServerControllerDelegate <NSObject>

@optional
- (void)didStartFetchingInfoForServerController:(id<AGServerControllerProtocol>)controller;
- (void)serverController:(id<AGServerControllerProtocol>)controller didFinishWithError:(NSError *)error;

@required
- (void)serverController:(id<AGServerControllerProtocol>)controller didFinishFetchingServerInfoWithOperation:(AGServerOperation *)operation;
- (void)serverController:(id<AGServerControllerProtocol>)controller didFinishFetchingServerStatusWithOperation:(AGServerOperation *)operation;

@end
