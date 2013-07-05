//
//  AltViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 21/06/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "AltViewController.h"

#import "Constants.h"

@interface AltViewController ()

@property UIView *altBackgroundView;

@end

@implementation AltViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.altBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.altBackgroundView setBackgroundColor:altViewBackgroundColor];
    [self.altBackgroundView setAlpha:translutentAlpha];
    [self.view addSubview:self.altBackgroundView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
