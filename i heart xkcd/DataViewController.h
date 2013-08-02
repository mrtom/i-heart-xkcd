//
//  DataViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAITrackedViewController.h"

@class ComicData;

@interface DataViewController : GAITrackedViewController <UIScrollViewDelegate, UIPopoverControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (strong, nonatomic) ComicData *dataObject;
@property UIImageView *imageView;

- (void)handleTap;
- (void)showTitle;
- (void)hideTitle;

- (CGPoint)comicOffset;
- (CGSize)comicSize;

@end
