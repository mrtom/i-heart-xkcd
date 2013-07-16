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

@property UIImageView *altBackgroundView;
@property UIView *altBackgroundCoverView;

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
    
    [self blurBackground];
}

- (void)blurBackground
{
    self.altBackgroundCoverView = [[UIView alloc] initWithFrame:self.view.bounds];
    //[self.altBackgroundCoverView setBackgroundColor:[UIColor blackColor]];
    //[self.altBackgroundCoverView setAlpha:0.4f];
    [self.altBackgroundCoverView setBackgroundColor:[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.6f]];
    [self.view addSubview:self.altBackgroundCoverView];
    [self.view sendSubviewToBack:self.altBackgroundCoverView];
    
    self.altBackgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    UIImage *theImage = [UIImage imageNamed:@"1238.png"];
    
    //create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    //setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    //CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    //add our blurred image to the view
    self.altBackgroundView.image = [UIImage imageWithCGImage:cgImage];
    
    [self.view addSubview:self.altBackgroundView];
    [self.view sendSubviewToBack:self.altBackgroundView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
