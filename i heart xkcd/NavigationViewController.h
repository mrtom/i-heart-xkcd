//
//  NavigationViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 05/02/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NavigationViewControllerProtocol.h"

@interface NavigationViewController : UIViewController<UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *controlsViewBacking;
@property (strong, nonatomic) IBOutlet UITableView *favouritePickerView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewSegmentAll;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewSegmentEnds;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewNextRandom;

@property (strong, nonatomic) id<NavigationViewControllerProtocol> delegate;
@property (nonatomic) NSInteger currentComic;

- (BOOL)isShowingControls;
- (void)showControls;
- (void)hideControls;

- (void)goPrevious;
- (void)goNext;

- (void)reloadFavourites;

-(IBAction) controlsViewSegmentAllIndexChanged;
-(IBAction) controlsViewSegmentEndsIndexChanged;
-(IBAction) controlsViewNextRandomIndexChanged;

@end
