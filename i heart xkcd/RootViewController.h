//
//  RootViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AltViewControllerProtocol.h"
#import "FavouritesViewControllerProtocol.h"
#import "ModelController.h"
#import "NavigationViewControllerProtocol.h"
#import "SearchViewControllerProtocol.h"
#import "TabBarDraggerProtocol.h"

@class TabBarDraggerViewController;

@interface RootViewController : UIViewController <UIPageViewControllerDelegate, ModelControllerDelegate, NavigationViewControllerProtocol, FavouritesViewControllerProtocol, AltViewControllerProtocol, UITabBarControllerDelegate, UIGestureRecognizerDelegate, TabBarDraggerProtocol, SearchViewControllerProtocol> {
    UIView *pageCover;
    UIView *turnPageForwardView;
    UIView *turnPageBackView;
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIView *pageCover;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) TabBarDraggerViewController *tabBarPull;

@end
