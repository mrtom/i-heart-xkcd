//
//  AltViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 21/06/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "AltViewController.h"

#import "Constants.h"

// FIXME: This shouldn't be here :(
#define TITLE_BAR_HEIGHT 20

@interface AltViewController ()

@property UIView *altBackgroundView; // A container for the image filling the TabBarControllers content
@property UIImageView *altBackgroundImageView; // The image itself, which may be bigger or smaller than the TabBarControllers content
@property UIView *altBackgroundCoverView; // Provides the color to the blur

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
    
    self.altBackgroundCoverView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.altBackgroundCoverView setBackgroundColor:[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.6f]];
    [self.view addSubview:self.altBackgroundCoverView];
    [self.view sendSubviewToBack:self.altBackgroundCoverView];
    
    self.altBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.altBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.altBackgroundView];
    [self.view sendSubviewToBack:self.altBackgroundView];
    
    [self blurBackground];
    [self.altBackgroundView addSubview:self.altBackgroundImageView];    
}

- (void)blurBackground
{
    UIImageView *comic = [self.delegate imageView];
    CGRect backgroundViewFrame = CGRectApplyAffineTransform(comic.frame, CGAffineTransformMakeTranslation(0, -TITLE_BAR_HEIGHT));
    
    self.altBackgroundImageView = [[UIImageView alloc] initWithFrame:backgroundViewFrame];
    UIImage *theImage = [[self.delegate imageView] image];
    NSLog(@"%@", [self.delegate comicData].title);
    
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
    self.altBackgroundImageView.image = [UIImage imageWithCGImage:cgImage];
}

- (void)handleToggleStarted
{
    [self blurBackground];
}

- (void)handleViewMoved:(CGPoint)centreLocationInSuperview
{
    // We need to move the origin of the background image view so it's centre
    // is always exactly the same as the centre of the AltViewControllers superview
    // Also, we're only scrolling in an x direction
    CGPoint imageLocation = CGPointMake(([self.view superview].bounds.size.width/2) - centreLocationInSuperview.x + self.altBackgroundView.bounds.size.width/2, self.altBackgroundView.center.y);
    self.altBackgroundView.center = imageLocation;
}

- (void)handleToggleAnimatingOpen:(CGPoint)centreLocationInSuperview
{
    CGPoint openOrigin = CGPointMake([self.view superview].bounds.size.width/2, self.altBackgroundView.center.y);
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{
                         self.altBackgroundView.center = openOrigin;
                     }
                     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
