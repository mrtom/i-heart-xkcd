//
//  FavouritesViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "FavouritesViewController.h"

@interface FavouritesViewController ()

@end

@implementation FavouritesViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Favourites", @"Favourites");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
