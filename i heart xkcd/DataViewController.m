//
//  DataViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "DataViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

#import "AboutViewController.h"
#import "ComicStore.h"
#import "ComicImageStore.h"
#import "ModelController.h"
#import "Settings.h"
#import "UIImage+animatedGIF.h"

#define pageOverlayToggleAnimationTime 0.300
#define pageOverlayToggleBounceLimit pageOverlayToggleAnimationTime+0.025

#define translutentAlpha 0.8
#define altTextBackgroundPadding 15           // Padding between the alt text background and the parent view
#define altTextPadding 10                     // Padding between the alt text and the alt text background
#define favouriteAndFacebookButtonSide 52
#define comicPadding altTextBackgroundPadding // Padding between the scroll view housing the comic and the parent view

#define comicIsFavouriteBackgroundImage @"heart"
#define comicIsNotFavouriteBackgroundImage @"heart_add"
#define isLoggedIntoFacebookBackgroundImage @"f_logo"
#define isNotLoggedIntoFacebookBackgroundImage @"f_logo_disabled"

typedef enum {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
} ScrollDirection;

@interface DataViewController ()

@property UIImageView *imageView;

@property UIView *altTextCanvasView;
@property UIView *altTextBackgroundView;
@property UIScrollView *altTextScrollView;
@property UILabel *altTextView;

@property UIView *aboutButtonBackground;
@property UIView *favouriteButtonBackground;
@property UIView *facebookShareButtonBackground;
@property UIButton *aboutButton;
@property UIButton *favouriteButton;
@property UIButton *facebookShareButton;

@property (readwrite, nonatomic) double lastTimeOverlaysToggled;
@property BOOL shouldHideTitle;
@property BOOL imageIsLargerThanScrollView;
@property BOOL wasAtMinimumLeft;
@property BOOL wasAtMaximumLeft;
@property float previousContentX;
@property ScrollDirection scrollDirection;

@property UIPopoverController *aboutPopover;

@end

@implementation DataViewController

@synthesize delegate, previousContentX;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // Alt text overlay
    self.altTextCanvasView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.altTextCanvasView setBackgroundColor:[UIColor clearColor]];
    [self.altTextCanvasView setAlpha:0];
    [self.view addSubview:self.altTextCanvasView];
    
    self.altTextBackgroundView = [[UIView alloc] init];
    [self.altTextBackgroundView setBackgroundColor:[UIColor blackColor]];
    [self.altTextBackgroundView setAlpha:translutentAlpha];
    [self.altTextCanvasView addSubview:self.altTextBackgroundView];
    
    self.altTextScrollView = [[UIScrollView alloc] init];
    [self.altTextCanvasView addSubview:self.altTextScrollView];
    
    self.altTextView = [[UILabel alloc] init];
    [self.altTextView setBackgroundColor:[UIColor clearColor]];
    [self.altTextView setTextColor:[UIColor whiteColor]];
    [self.altTextView setNumberOfLines:0];
    
    self.altTextScrollView.minimumZoomScale=1.0;
    self.altTextScrollView.maximumZoomScale=1.0;
    self.altTextScrollView.clipsToBounds = YES;
    self.altTextScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    [self.altTextScrollView setBackgroundColor:[UIColor clearColor]];
    [self.altTextScrollView setScrollEnabled:YES];
    [self.altTextScrollView addSubview:self.altTextView];
    
    // About, Favourite and Facebook buttons
    self.aboutButtonBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, favouriteAndFacebookButtonSide, favouriteAndFacebookButtonSide)];
    [self.aboutButtonBackground setBackgroundColor:[UIColor blackColor]];
    [self.aboutButtonBackground setAlpha:translutentAlpha];
    [self.altTextCanvasView addSubview:self.aboutButtonBackground];
    
    self.aboutButton = [[UIButton alloc] initWithFrame:self.aboutButtonBackground.frame];
    [self.aboutButton setBackgroundColor:[UIColor clearColor]];
    [self.aboutButton setBackgroundImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    [self.aboutButton addTarget:self action:@selector(aboutXkcd:) forControlEvents:UIControlEventTouchUpInside];
    [self.aboutButton setUserInteractionEnabled:YES];
    [self.altTextCanvasView addSubview:self.aboutButton];
    
    CGRect favouriteButtonFrame = self.aboutButtonBackground.frame;
    favouriteButtonFrame.origin.x += favouriteAndFacebookButtonSide;
    self.favouriteButtonBackground = [[UIView alloc] initWithFrame:favouriteButtonFrame];
    [self.favouriteButtonBackground setBackgroundColor:[UIColor blackColor]];
    [self.favouriteButtonBackground setAlpha:translutentAlpha];
    [self.altTextCanvasView addSubview:self.favouriteButtonBackground];
    
    self.favouriteButton = [[UIButton alloc] initWithFrame:self.favouriteButtonBackground.frame];
    [self.favouriteButton setBackgroundColor:[UIColor clearColor]];
    [self.favouriteButton setBackgroundImage:[UIImage imageNamed:comicIsNotFavouriteBackgroundImage] forState:UIControlStateNormal];
    [self.favouriteButton addTarget:self action:@selector(toggleFavourite:) forControlEvents:UIControlEventTouchUpInside];
    [self.favouriteButton setUserInteractionEnabled:YES];
    [self.altTextCanvasView addSubview:self.favouriteButton];
    
    CGRect shareButtonFrame = self.favouriteButtonBackground.frame;
    shareButtonFrame.origin.x += favouriteAndFacebookButtonSide;
    self.facebookShareButtonBackground = [[UIView alloc] initWithFrame:shareButtonFrame];
    [self.facebookShareButtonBackground setBackgroundColor:[UIColor blackColor]];
    [self.facebookShareButtonBackground setAlpha:translutentAlpha];
    [self.altTextCanvasView addSubview:self.facebookShareButtonBackground];
    
    self.facebookShareButton = [[UIButton alloc] initWithFrame:self.facebookShareButtonBackground.frame];
    [self.facebookShareButton setBackgroundColor:[UIColor clearColor]];
    [self.facebookShareButton setBackgroundImage:[UIImage imageNamed:@"f_logo_disabled"] forState:UIControlStateNormal];
    [self.facebookShareButton addTarget:self action:@selector(facebookShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookShareButton setUserInteractionEnabled:YES];
    [self.altTextCanvasView addSubview:self.facebookShareButton];
    
    // Setup controls
    [self.controlsViewCanvas setAlpha:0];
    [self.favouritePickerView setDelegate:self];
    [self.favouritePickerView setDataSource:[ComicStore sharedStore]];
    
    // Setup gesture recognisers
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.lastTimeOverlaysToggled = 0;
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTapRecognizer];

    // Setup internal state
    self.wasAtMinimumLeft = NO;
    self.wasAtMaximumLeft = NO;
    self.previousContentX = 0.0f;
    self.scrollDirection = ScrollDirectionNone;
    
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
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
            [[ComicImageStore sharedStore] pushComic:self.dataObject withImage:image];
            
        } failure:nil];
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"#%u: %@", [self.dataObject comicID], [self.dataObject safeTitle]];
    
    // Setup the alt text view
    [self configureAltTextViews];
    
    // Check segment state
    [self configureSegmentedControlsState];
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

-(void)configureAltTextViews
{
    NSString *altText = [[self dataObject] alt];
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *labelFont = [UIFont systemFontOfSize:17];
    [self.altTextView setText:altText];
    [self.altTextView setFont:labelFont];
    [self.altTextView setLineBreakMode:lineBreakMode];
    
    float titleBarHeight = self.titleLabel.frame.size.height;
    float maxWidthForAltText  = self.view.bounds.size.width - 2*altTextBackgroundPadding - 2*altTextPadding;
    float maxHeightForAltText = self.view.bounds.size.height - 2*altTextBackgroundPadding - 2*altTextPadding - titleBarHeight - favouriteAndFacebookButtonSide;
    
    CGSize altTextSize = [altText sizeWithFont:labelFont constrainedToSize:CGSizeMake(maxWidthForAltText, 9999) lineBreakMode:lineBreakMode];
    
    float altTextScrollWidth = MIN(altTextSize.width, maxWidthForAltText);
    float altTextScrollHeight = MIN(altTextSize.height, maxHeightForAltText);
    
    [self.altTextView setFrame:CGRectMake(0, 0, altTextSize.width, altTextSize.height)];
    
    [self.altTextScrollView setFrame:CGRectMake((altTextPadding+altTextBackgroundPadding),
                                                (altTextPadding+altTextBackgroundPadding+titleBarHeight),
                                                altTextScrollWidth, altTextScrollHeight)];
    self.altTextScrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2+titleBarHeight/2);
    [self.altTextScrollView setContentSize:self.altTextView.bounds.size];
    
    [self.altTextBackgroundView setFrame:CGRectMake(altTextBackgroundPadding,
                                                    (altTextBackgroundPadding+titleBarHeight),
                                                    altTextScrollWidth+2*altTextPadding, altTextScrollHeight+2*altTextPadding)];
    self.altTextBackgroundView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2+titleBarHeight/2);
    
    // Place About, Favourite and FB Share buttons directly on top of alttextview
    CGRect altTextFrame = [self.altTextBackgroundView frame];
    CGRect aboutFrame = [self.aboutButtonBackground frame];
    CGRect favFrame = [self.favouriteButtonBackground frame];
    CGRect fbFrame = [self.facebookShareButtonBackground frame];
    
    aboutFrame.origin.x = altTextFrame.origin.x;
    favFrame.origin.x = aboutFrame.origin.x + favouriteAndFacebookButtonSide;
    fbFrame.origin.x = favFrame.origin.x + favouriteAndFacebookButtonSide;
    
    aboutFrame.origin.y = altTextFrame.origin.y - favouriteAndFacebookButtonSide;
    favFrame.origin.y = aboutFrame.origin.y;
    fbFrame.origin.y = aboutFrame.origin.y;
    
    [self.aboutButtonBackground setFrame:aboutFrame];
    [self.favouriteButtonBackground setFrame:favFrame];
    [self.facebookShareButtonBackground setFrame:fbFrame];
    [self.aboutButton setFrame:aboutFrame];
    [self.favouriteButton setFrame:favFrame];
    [self.facebookShareButton setFrame:fbFrame];
    
    if ([self.dataObject isFavourite]) {
        [self.favouriteButton setBackgroundImage:[UIImage imageNamed:comicIsFavouriteBackgroundImage] forState:UIControlStateNormal];
    } else {
        [self.favouriteButton setBackgroundImage:[UIImage imageNamed:comicIsNotFavouriteBackgroundImage] forState:UIControlStateNormal];
    }
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [self.facebookShareButton setBackgroundImage:[UIImage imageNamed:isLoggedIntoFacebookBackgroundImage] forState:UIControlStateNormal];
    } else {
        [self.facebookShareButton setBackgroundImage:[UIImage imageNamed:isNotLoggedIntoFacebookBackgroundImage] forState:UIControlStateNormal];
    }
}

-(void)configureSegmentedControlsState
{
    if ([self.dataObject comicID] == 1 || [self.dataObject comicID] == 0) {
        if (self.controlsViewSegmentEnds) [self.controlsViewSegmentEnds setEnabled:NO forSegmentAtIndex:0];
        if (self.controlsViewNextRandom)  [self.controlsViewNextRandom setEnabled:NO forSegmentAtIndex:0];
        if (self.controlsViewSegmentAll) {
            [self.controlsViewSegmentAll setEnabled:NO forSegmentAtIndex:0];
            [self.controlsViewSegmentAll setEnabled:NO forSegmentAtIndex:1];
        }
    } else {
        if (self.controlsViewSegmentEnds) [self.controlsViewSegmentEnds setEnabled:YES forSegmentAtIndex:0];
        if (self.controlsViewNextRandom)  [self.controlsViewNextRandom setEnabled:YES forSegmentAtIndex:0];
        if (self.controlsViewSegmentAll) {
            [self.controlsViewSegmentAll setEnabled:YES forSegmentAtIndex:0];
            [self.controlsViewSegmentAll setEnabled:YES forSegmentAtIndex:1];
        }
    }
    
    int latestPage = [[NSUserDefaults standardUserDefaults] integerForKey:iheartxkcd_UserDefaultLatestPage];
    if ([self.dataObject comicID] == latestPage) {
        if (self.controlsViewSegmentEnds) [self.controlsViewSegmentEnds setEnabled:NO forSegmentAtIndex:1];
        if (self.controlsViewNextRandom)  [self.controlsViewNextRandom setEnabled:NO forSegmentAtIndex:2];
        if (self.controlsViewSegmentAll) {
            [self.controlsViewSegmentAll setEnabled:NO forSegmentAtIndex:3];
            [self.controlsViewSegmentAll setEnabled:NO forSegmentAtIndex:4];
        }
    } else {
        if (self.controlsViewSegmentEnds) [self.controlsViewSegmentEnds setEnabled:YES forSegmentAtIndex:1];
        if (self.controlsViewNextRandom)  [self.controlsViewNextRandom setEnabled:YES forSegmentAtIndex:2];
        if (self.controlsViewSegmentAll) {
            [self.controlsViewSegmentAll setEnabled:YES forSegmentAtIndex:3];
            [self.controlsViewSegmentAll setEnabled:YES forSegmentAtIndex:4];
        }
    }
}

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
    [self configureView];
}

#pragma mark - Handle gestures and touches

- (BOOL)canToggleOverlays
{
    double timeNow = CACurrentMediaTime();
    if (timeNow - self.lastTimeOverlaysToggled < pageOverlayToggleBounceLimit) {
        return NO;
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && [self canToggleOverlays]) {
        self.lastTimeOverlaysToggled = CACurrentMediaTime();
        
        [self toggleTitleAndAltText];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && [self canToggleOverlays]) {
        self.lastTimeOverlaysToggled = CACurrentMediaTime();
        
        [self toggleControls];
    }
}

- (void)animateShowTitleBar
{
    // If we shouldn't hide it, it'll never be hidden, so we don't have to do anything
    if (self.shouldHideTitle) {
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.titleLabel.alpha = translutentAlpha;}
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

- (void)toggleTitleAndAltText
{
    if ([self.altTextCanvasView alpha] == 0) {
        [self showTitleAndAltText];
    } else {
        [self hideTitleAndAltText];
    }
}

- (void)showTitleAndAltText
{
    [self hideControls];
    [self.scrollView setScrollEnabled:NO];
    
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{self.altTextCanvasView.alpha = 1.0;}
                     completion:nil];
    [self animateShowTitleBar];
}

- (void)hideTitleAndAltText
{
    [self.scrollView setScrollEnabled:YES];
    
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{self.altTextCanvasView.alpha = 0;}
                     completion:nil];
    [self animateHideTitleBar];
}

- (void)toggleControls
{
    if ([self.controlsViewCanvas alpha] == 0) {
        [self showControls];
    } else {
        [self hideControls];
    }
}

- (void)showControls
{
    [self hideTitleAndAltText];
    [self.scrollView setScrollEnabled:NO];

    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{self.controlsViewCanvas.alpha = 1.0;}
                     completion:nil];
    [self animateShowTitleBar];
}

- (void)hideControls
{
    [self.scrollView setScrollEnabled:YES];
    
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{self.controlsViewCanvas.alpha = 0;}
                     completion:nil];
    [self animateHideTitleBar];
}

- (void)aboutXkcd: (id)sender
{
    AboutViewController *content = [[AboutViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:content];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)toggleFavourite: (id)sender
{
    BOOL didSet = YES;
    ComicImageStore *imageStore = [ComicImageStore sharedStore];
    
    if ([self.dataObject isFavourite]) {
        [self.dataObject setIsFavourite:NO];
        [[ComicStore sharedStore] setAsNotFavourite:self.dataObject];
   
        if ([Settings shouldCacheFavourites]) {
            didSet = [imageStore removeFavourite:self.dataObject];
        }
        if (didSet) {
            [self.favouriteButton setBackgroundImage:[UIImage imageNamed:comicIsNotFavouriteBackgroundImage] forState:UIControlStateNormal];            
        }
    } else {
        [self.dataObject setIsFavourite:YES];
        [[ComicStore sharedStore] setAsFavourite:self.dataObject];
        
        if ([Settings shouldCacheFavourites]) {
            didSet = [imageStore pushComic:self.dataObject withImage:[self.imageView image]];
        }
        if (didSet) {
            [self.favouriteButton setBackgroundImage:[UIImage imageNamed:comicIsFavouriteBackgroundImage] forState:UIControlStateNormal];
        }
    }
    
    ComicStore *store = [ComicStore sharedStore];
    [store addComic:self.dataObject];
    [store saveChanges];
}

- (void)facebookShare: (id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [FBNativeDialogs presentShareDialogModallyFrom:self
                                           initialText:nil
                                                 image:[self.imageView image]
                                                   url:[self.dataObject imageURL]
                                               handler:nil];

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login Needed" message:@"You must log into Facebook in your settings before you can post to Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Comic control
-(IBAction)controlsViewSegmentAllIndexChanged
{
    switch (self.controlsViewSegmentAll.selectedSegmentIndex) {
        case 0:
            [self goFirst];
            break;
        case 1:
            [self goPrevious];
            break;
        case 2:
            [self goRandom];
            break;
        case 3:
            [self goNext];
            break;
        case 4:
            [self goLast];
            break;
    }
    [self.controlsViewSegmentAll setSelectedSegmentIndex:UISegmentedControlNoSegment];
}
-(IBAction)controlsViewSegmentEndsIndexChanged
{
    switch (self.controlsViewSegmentEnds.selectedSegmentIndex) {
        case 0:
            [self goFirst];
            break;
        case 1:
            [self goLast];
            break;
    }
    [self.controlsViewSegmentEnds setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

-(IBAction)controlsViewNextRandomIndexChanged
{
    switch (self.controlsViewNextRandom.selectedSegmentIndex) {
        case 0:
            [self goPrevious];
            break;
        case 1:
            [self goRandom];
            break;
        case 2:
            [self goNext];
            break;
    }
    [self.controlsViewNextRandom setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

- (void)goFirst
{
    [self.delegate loadFirstComic];
}

- (void)goLast
{
    [self.delegate loadLastComic];
}

- (void)goPrevious
{
    [self.delegate loadPreviousComic];
}

- (void)goRandom
{
    [self.delegate loadRandomComic];
}

- (void)goNext
{
    [self.delegate loadNextComic];
}

#pragma mark - UIScrollViewDelegate classes
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    float currentOffset = scrollView.contentOffset.x;
    if (currentOffset <= 0.0f) {
        self.wasAtMinimumLeft = YES;
    }
    
    if (currentOffset >= ([self imageView].frame.size.width - [self scrollView].frame.size.width)) {
        self.wasAtMaximumLeft = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.previousContentX > scrollView.contentOffset.x) {
        self.scrollDirection = ScrollDirectionRight;
    } else if (self.previousContentX < scrollView.contentOffset.x) {
        self.scrollDirection = ScrollDirectionLeft;        
    }
    
    self.previousContentX = scrollView.contentOffset.x;
    
    if (self.wasAtMinimumLeft && self.scrollDirection == ScrollDirectionRight) {
        [self.scrollView setScrollEnabled:NO];
        [self goPrevious];
    } else if (self.wasAtMaximumLeft && self.scrollDirection == ScrollDirectionLeft) {
        [self.scrollView setScrollEnabled:NO];
        [self goNext];
    }
    self.wasAtMinimumLeft = NO;
    self.wasAtMaximumLeft = NO;
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ComicStore *store = [ComicStore sharedStore];
    NSArray *comics = [store favouriteComicsByKey];
    ComicData *comicForRow = [store comicForKey:[comics objectAtIndex:row]];
    NSLog(@"Title for row %u is %@", row, [comicForRow safeTitle]);
    
    return [NSString stringWithFormat:@"%@", [comicForRow safeTitle]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    ComicStore *store = [ComicStore sharedStore];
    NSArray *comics = [store favouriteComicsByKey];
    ComicData *comicForRow = [store comicForKey:[comics objectAtIndex:row]];
    
    [self.delegate loadComicAtIndex:[comicForRow comicID]];
}

@end
