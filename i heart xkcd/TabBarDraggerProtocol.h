//
//  TabBarDraggerProtocol.h
//  i heart xkcd
//
//  Created by Tom Elliott on 12/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TabBarDraggerProtocol <NSObject>

@required
- (void)handleTabBarDragged:(UIPanGestureRecognizer *)sender;
- (void)handleTabBarTapped:(UITapGestureRecognizer *)sender;

@end
