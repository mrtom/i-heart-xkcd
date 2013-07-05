//
//  RootViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelController.h"
#import "DataViewController.h"
#import "AltTextViewControllerProtocol.h"
#import "FavouritesViewControllerProtocol.h"
#import "NavigationViewControllerProtocol.h"

@interface RootViewController : UIViewController <UIPageViewControllerDelegate, ModelControllerDelegate, NavigationViewControllerProtocol, FavouritesViewControllerProtocol, AltTextViewControllerProtocol, UITabBarControllerDelegate> {
    UIView *pageCover;
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIView *pageCover;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end