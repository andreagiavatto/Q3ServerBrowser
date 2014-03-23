//
//  AGServerControllerProtocol.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 3/16/14.
//
//

#import <Foundation/Foundation.h>

@protocol AGServerControllerDelegate;


@protocol AGServerControllerProtocol <NSObject>

@property (nonatomic, weak) id<AGServerControllerDelegate> delegate;

- (void)infoForServerWithIp:(NSString *)ip andPort:(NSString *)port;

@end
