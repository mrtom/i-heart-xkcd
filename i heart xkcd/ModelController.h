//
//  ModelController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataViewControlsProtocol.h"

#define iheartxkcd_UserDefaultLatestPage @"latestPage"
#define iheartxkcd_UserDefaultLastUpdate @"lastUpdate"

@class DataViewController;
@class ComicData;

@protocol ModelControllerDelegate <NSObject>
@required
- (void) handleLatestComicLoaded:(NSInteger) index;
@end

@interface ModelController : NSObject <UIPageViewControllerDataSource>

@property (strong, nonatomic) id<ModelControllerDelegate, DataViewControlsProtocol> delegate;

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;
- (NSUInteger)indexOfLastComic;

FOUNDATION_EXPORT NSString *const XKCD_API;

@end
