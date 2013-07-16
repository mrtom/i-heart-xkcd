//
//  TabBarDraggerViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 12/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TabBarDraggerProtocol.h"

@interface TabBarDraggerViewController : UIViewController

@property (strong, nonatomic) id<TabBarDraggerProtocol> delegate;

- (id)initWithDelegate:(id<TabBarDraggerProtocol>) delegate;

@end
