//
//  AGQ3Parser.h
//  AGServerBrowser
//
//  Created by Andrea Giavatto on 12/14/13.
//
//

#import <Foundation/Foundation.h>

#import "AGParserProtocol.h"
#import "AGParserDelegate.h"

@interface AGQ3Parser : NSObject <AGParserProtocol>

@property (nonatomic, weak) id<AGParserDelegate> delegate;

@end
