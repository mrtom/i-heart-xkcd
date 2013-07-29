//
//  AltViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 21/06/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AltViewControllerProtocol.h"
#import "GAITrackedViewController.h"

@interface AltViewController : GAITrackedViewController {

}

@property (nonatomic, strong) id<AltViewControllerProtocol> delegate;

- (void)handleToggleStarted;
- (void)handleViewMoved:(CGPoint)centreLocationInSuperview;
- (void)handleToggleAnimatingOpen:(CGPoint)centreLocationInSuperview;
- (void)handleToggleAnimatingClosed:(CGPoint)centreLocationInSuperview;

@end
