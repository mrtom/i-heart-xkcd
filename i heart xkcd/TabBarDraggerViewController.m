//
//  TabBarDraggerViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 12/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "TabBarDraggerViewController.h"

#define TabBarDraggerViewControllerWidth  30
#define TabBarDraggerViewControllerHeight 50

@interface TabBarDraggerViewController ()

@end

@implementation TabBarDraggerViewController

- (id)initWithDelegate:(id<TabBarDraggerProtocol>) delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set size
    CGRect bounds = self.view.bounds;
    bounds.size.width = TabBarDraggerViewControllerWidth;
    bounds.size.height = TabBarDraggerViewControllerHeight;
    
    [self.view setBounds:bounds];
    
    // Set visuals
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TabBarPull.png"]]];
    [self.view setAlpha:0.8f];
    
    // Setup Gesture Recognizers
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(handleTabBarDragged:)];
    panGR.maximumNumberOfTouches = 1;
    panGR.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGR];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(handleTabBarTapped:)];
    tapGR.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGR];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
