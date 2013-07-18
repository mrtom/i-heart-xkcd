//
//  DataViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//
// FIXME: I've simplifeid this a lot, you can always set scroll to enabled now. This class can have a bunch of shite rmeoved

#import "DataViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

#import "Constants.h"
#import "GAI.h"
#import "ComicStore.h"
#import "ComicImageStore.h"

#import "ModelController.h"
#import "NavigationViewController.h"
#import "Settings.h"
#import "UIImage+animatedGIF.h"

typedef enum {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
} ScrollDirection;

@interface DataViewController ()

@property BOOL isShowingInfo;
@property BOOL shouldHideTitle;
@property BOOL imageIsLargerThanScrollView;
@property BOOL wasAtMinimumLeft;
@property BOOL wasAtMaximumLeft;
@property float previousContentX;
@property ScrollDirection scrollDirection;

@end

@implementation DataViewController

@synthesize previousContentX;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.trackedViewName = @"Data View Controller";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isShowingInfo = NO;
    self.shouldHideTitle = NO;
    self.imageIsLargerThanScrollView = NO;
    
    self.imageView = [[UIImageView alloc] init];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.scrollView];
    [self.view sendSubviewToBack:self.scrollView];
    
    self.scrollView.minimumZoomScale=1.0;
    self.scrollView.maximumZoomScale=1.0;
    self.scrollView.bouncesZoom = NO;
    self.scrollView.delegate=self;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    [self.scrollView setScrollEnabled:YES];
    
    [self.scrollView addSubview:self.imageView];
    
    // Setup internal state
    self.wasAtMinimumLeft = NO;
    self.wasAtMaximumLeft = NO;
    self.previousContentX = 0.0f;
    self.scrollDirection = ScrollDirectionNone;    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [self configureView];
}

#pragma mark - View configuration

- (void)configureView
{
    DataViewController *this = self;
    [self.scrollView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    UIImage *placeHolderImage = [UIImage imageNamed:@"terrible_small_logo"];
    
    CGSize imageSize;
    imageSize = CGSizeMake(placeHolderImage.size.width, placeHolderImage.size.height);
    self.scrollView.contentSize = imageSize;
    [self.imageView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    self.imageView.center = CGPointMake((self.scrollView.bounds.size.width/2),(self.scrollView.bounds.size.height/2));

    // 404 doesn't exist - heh. If it's 404, just ignore
    if ([self.dataObject comicID] == 404) {
        [self checkLoadedState];
    } else {
        // Note: The scale stuff here is a *lot* hacky.
        // Asumption: The comics have been designed to look good at about 1024, i.e. a 'normal' web viewing experience
        // This means they should be doubled up on the retina iPad, but not the other iOS devices.
        // However, when we save the image to the image store, we store it doubled up, so don't double again
        ComicImageStore *imageStore = [ComicImageStore sharedStore];
        UIImage *storedImage = [imageStore imageForComic:self.dataObject];
        if (storedImage) {
            [self.imageView setImage:storedImage];
            [self configureImageLoadedFromXkcdWithImage:storedImage forScale:1];
        } else {
            // Get the image from XKCD. This is async!
            [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[self.dataObject imageURL]] placeholderImage:placeHolderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                
                NSInteger scale = 1;
                if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                    ([UIScreen mainScreen].scale == 2.0)) {
                    // Retina display
                    scale = 2;
                }
                
                [this configureImageLoadedFromXkcdWithImage:image forScale:scale];
                [[ComicImageStore sharedStore] pushComic:this.dataObject withImage:image];
                
            } failure:nil];
        }
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"#%u: %@", [self.dataObject comicID], [self.dataObject safeTitle]];
    
    // Check segment state
    //[self.navViewController setCurrentComic:[self.dataObject comicID]];
    // TODO: Make pub sub
}

-(void)configureImageLoadedFromXkcdWithImage:(UIImage *)image forScale:(NSInteger)scale
{
    // Set the content view to be the size of the comic image size
    CGSize comicSize;
    
    comicSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
    CGSize comicWithPaddingSize = CGSizeMake(comicSize.width+2*comicPadding, comicSize.height+2*comicPadding);
    
    self.scrollView.contentSize = comicWithPaddingSize;
    
    // If gif, start animating
    NSString *urlString = [[self.dataObject imageURL] absoluteString];
    if ([@"gif" isEqualToString:[urlString substringFromIndex:[urlString length]-3]]) {
        // FIXME: Would be good if we could set the proper duration, not just make one up
        // FIXME: Should also refactor and move this outside the AFNetworking code, so we don't fetch it twice
        image = [UIImage animatedImageWithAnimatedGIFURL:[self.dataObject imageURL] duration:30];
    }
    
    [self.imageView setFrame:CGRectMake(comicPadding, comicPadding, comicSize.width, comicSize.height)];
    [self.imageView setImage:image];
    
    // Canvas size is the total 'drawable' size within the scroll view content area, ie not including the padding
    CGSize canvasSize = CGSizeMake(self.scrollView.bounds.size.width-2*comicPadding, self.scrollView.bounds.size.height-2*comicPadding);
    
    // Assume image is smaller than view and center it
    self.imageView.center = CGPointMake((self.scrollView.bounds.size.width/2),(self.scrollView.bounds.size.height/2));
    
    // Check if this is actually true. If not, set to 0 and allow scroll view to handle position
    if (self.imageView.frame.size.width > canvasSize.width) {
        self.imageIsLargerThanScrollView = YES;
        
        CGRect currentRect = self.imageView.frame;
        currentRect.origin.x = comicPadding;
        [self.imageView setFrame:currentRect];
    }
    if (self.imageView.frame.size.height > canvasSize.height) {
        self.imageIsLargerThanScrollView = YES;
        
        CGRect currentRect = self.imageView.frame;
        currentRect.origin.y = comicPadding;
        [self.imageView setFrame:currentRect];
    }
    
    // If image is larger than scroll view, allow it to be shrunk
    if (self.imageIsLargerThanScrollView) {
        self.scrollView.bouncesZoom = YES;
        float zoomScale = MIN(canvasSize.width/comicSize.width, canvasSize.height/comicSize.height);
        self.scrollView.minimumZoomScale = zoomScale;
    }
    
    // Fade out the title if it's covering the image
    self.shouldHideTitle = (self.imageView.frame.origin.y < self.titleLabel.frame.size.height);
    if (self.shouldHideTitle) {
        [UIView animateWithDuration:2+pageOverlayToggleAnimationTime
                         animations:^{self.titleLabel.alpha = 0;}
                         completion:nil];
    }
    
    [self checkLoadedState];
}

//-(void)configureNavigationViews
//{
//    // Place at the centre horizontally, and at the base vertically
//    CGRect navViewFrame = self.navViewController.view.frame;
//    
//    NSInteger x = self.view.bounds.size.width/2 - navViewFrame.size.width/2;
//    NSInteger y = self.view.bounds.size.height - altTextBackgroundPadding - navViewFrame.size.height;
//    navViewFrame.origin.x = x;
//    navViewFrame.origin.y = y;
//    
//    [self.navViewController.view setFrame:navViewFrame];
//}

-(void)checkLoadedState
{
    if ([self.dataObject isLoaded]) {
        [self.loadingView stopAnimating];
    } else {
        [self.loadingView startAnimating];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self configureView];
}

- (void)setDataObject:(ComicData *)dataObject
{
    _dataObject = dataObject;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"ComicLoaded"
                        withAction:@""
                         withLabel:[NSString stringWithFormat:@"%d", [dataObject comicID]]
                         withValue:[NSNumber numberWithInt:[dataObject comicID]]];
    
    [self configureView];
}

#pragma mark - Handle gestures and touches

- (void)handleTap {
    [self toggleTitle];
}

- (void)animateShowTitleBar
{
    // If we shouldn't hide it, it'll never be hidden, so we don't have to do anything
    if (self.shouldHideTitle) {
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.titleLabel.alpha = 1.0f;}
                         completion:nil];
    }
}

- (void)animateHideTitleBar
{
    if (self.shouldHideTitle) {
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.titleLabel.alpha = 0;}
                         completion:nil];
    }
}

- (void)toggleTitle
{
    if (!self.isShowingInfo) {
        [self showTitle];
    } else {
        [self hideTitle];
    }
}

- (void)showTitle
{
    [self.scrollView setScrollEnabled:NO];
    [self animateShowTitleBar];
    self.isShowingInfo = YES;
}

- (void)hideTitle
{
    [self.scrollView setScrollEnabled:YES];
    [self animateHideTitleBar];
    self.isShowingInfo = NO;
}

#pragma mark - UIScrollViewDelegate classes

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

@end
