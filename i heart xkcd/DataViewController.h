//
//  DataViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ComicData.h"
#import "ModelController.h"
#import "DataViewControlsProtocol.h"

@interface DataViewController : UIViewController <UIScrollViewDelegate, UIPopoverControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (strong, nonatomic) IBOutlet UIView *controlsViewBacking;
@property (strong, nonatomic) IBOutlet UIView *controlsViewCanvas;
@property (strong, nonatomic) IBOutlet UITableView *favouritePickerView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewSegmentAll;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewSegmentEnds;
@property (strong, nonatomic) IBOutlet UISegmentedControl *controlsViewNextRandom;

@property (strong, nonatomic) id<DataViewControlsProtocol> delegate;

@property (strong, nonatomic) ComicData *dataObject;

-(IBAction) controlsViewSegmentAllIndexChanged;
-(IBAction) controlsViewSegmentEndsIndexChanged;
-(IBAction) controlsViewNextRandomIndexChanged;

@end
