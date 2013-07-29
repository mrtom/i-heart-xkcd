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
@property CGSize comicSize;
@property CGPoint comicOffset;

@property (nonatomic, strong) UIView *altBackgroundView; // A container for the image filling the TabBarControllers content
@property (nonatomic, strong) UIImageView *altBackgroundImageView; // The image itself, which may be bigger or smaller than the TabBarControllers content
@property (nonatomic, strong) UIView *altBackgroundCoverView; // Provides the color to the blur

@end

@implementation AltViewController

@synthesize altBackgroundView, altBackgroundImageView, altBackgroundCoverView;

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
    // TODO: When the TabBarController is visible and you switch views, make sure the filtered image is in the right location
    [super viewDidLoad];
    
    self.altBackgroundCoverView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.altBackgroundCoverView setBackgroundColor:[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.6f]];
    [self.view addSubview:self.altBackgroundCoverView];
    [self.view sendSubviewToBack:self.altBackgroundCoverView];
    
    self.altBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.altBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.altBackgroundView];
    [self.view sendSubviewToBack:self.altBackgroundView];

    self.altBackgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.altBackgroundView addSubview:self.altBackgroundImageView];
    
    [self blurBackground];
}

- (void)blurBackground
{
    UIImageView *comic = [self.delegate comicImage];
    
    CGRect backgroundImageViewFrame = CGRectApplyAffineTransform(comic.frame, CGAffineTransformMakeTranslation(0, -TITLE_BAR_HEIGHT));
    self.altBackgroundImageView.frame = backgroundImageViewFrame;
    UIImage *theImage = [comic image];
    
    //create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    //setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    //CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    //add our blurred image to the view
    [self.altBackgroundImageView setImage:[UIImage imageWithCGImage:cgImage]];
}

- (void)handleToggleStarted
{
    // TODO: We should run blurBackground when the comic is chosen, using pub/sub. Not when toggling is started
    // (as it performs an expensive operation immediately that could be pre-rendered)
    [self blurBackground];
    self.comicSize = [self.delegate comicSize];
    self.comicOffset = [self.delegate comicOffset];
}

- (void)handleViewMoved:(CGPoint)centreLocationInSuperview
{
    // We need to move the origin of the background image view so it's centre
    // is always exactly the same as the centre of the AltViewControllers superview
    CGPoint imageLocation = CGPointMake(
                                        ([self.view superview].bounds.size.width/2) - centreLocationInSuperview.x + self.altBackgroundView.bounds.size.width/2 - self.comicOffset.x,
                                        self.altBackgroundView.center.y - self.comicOffset.y
                                        );
    self.altBackgroundView.center = imageLocation;
}

- (void)handleToggleAnimatingOpen:(CGPoint)centreLocationInSuperview
{
    CGPoint openOrigin = CGPointMake(
                                     [self.view superview].bounds.size.width/2 - self.comicOffset.x,
                                     self.altBackgroundView.center.y - self.comicOffset.y
                                     );
    [self animateImageTo:openOrigin];
    
}

- (void)handleToggleAnimatingClosed:(CGPoint)centreLocationInSuperview
{
    CGPoint closeOrigin = CGPointMake(
                                     -[self.view superview].bounds.size.width/2 - self.comicOffset.x,
                                     self.altBackgroundView.center.y - self.comicOffset.y
                                     );
    [self animateImageTo:closeOrigin];
}

- (void)animateImageTo:(CGPoint)location
{
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{
                         self.altBackgroundView.center = location;
                     }
                     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
