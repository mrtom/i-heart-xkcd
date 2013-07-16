//
//  NavigationViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 05/02/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AltViewController.h"
#import "NavigationViewControllerProtocol.h"

@interface NavigationViewController : AltViewController<UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *controlsViewBacking;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewSegmentAll;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewSegmentEnds;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewNextRandom;

@property (strong, nonatomic) id<NavigationViewControllerProtocol> delegate;
@property (nonatomic) NSInteger currentComic;

- (void)goPrevious;
- (void)goNext;

-(IBAction) controlsViewSegmentAllIndexChanged;
-(IBAction) controlsViewSegmentEndsIndexChanged;
-(IBAction) controlsViewNextRandomIndexChanged;

@end
