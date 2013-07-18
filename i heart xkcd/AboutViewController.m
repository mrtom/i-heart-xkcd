//
//  AboutViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 03/01/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.trackedViewName = @"About View Controller";
        self.title = NSLocalizedString(@"About", @"About");
        self.tabBarItem.image = [UIImage imageNamed:@"TabBarAbout.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.aboutXkcdTitle setNumberOfLines:1];
    [self.aboutIHeartXkcdTitle setNumberOfLines:1];
    [self.aboutIHeartXkcdTitle setNumberOfLines:1];
    [self.aboutIHeartXkcdTitle setNumberOfLines:1];

    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.aboutXkcdBody setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.aboutXkcdTitle setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.aboutIHeartXkcdBody setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.aboutIHeartXkcdTitle setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    NSLog(@"%f, %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"%f, %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.aboutXkcdBody sizeToFit];
    [self.aboutIHeartXkcdBody sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
