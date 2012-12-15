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
#import "UIImage+animatedGIF.h"
#import "ModelController.h"

#define pageOverlayToggleAnimationTime 0.300
#define pageOverlayToggleBounceLimit pageOverlayToggleAnimationTime+0.025

#define altTextBackgroundPadding 15 // Padding between the alt text background and the parent view
#define altTextPadding 10           // Padding between the alt text and the alt text background

@interface DataViewController ()

@property UIImageView *imageView;
@property UIView *altTextBackgroundView;
@property UIScrollView *altTextScrollView;
@property UILabel *altTextView;

@property (readwrite, nonatomic) double lastTimeOverlaysToggled;
@property BOOL shouldHideTitle;
@property BOOL imageIsLargerThanScrollView;

@end

@implementation DataViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldHideTitle = NO;
    self.imageIsLargerThanScrollView = NO;
    
    self.imageView = [[UIImageView alloc] init];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.scrollView];
    [self.view sendSubviewToBack:self.scrollView];
    
    self.scrollView.minimumZoomScale=0.1;
    self.scrollView.maximumZoomScale=1.0;
    self.scrollView.delegate=self;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    [self.scrollView setScrollEnabled:YES];
    
    [self.scrollView addSubview:self.imageView];
    
    // Alt text overlay
    self.altTextBackgroundView = [[UIView alloc] init];
    [self.altTextBackgroundView setAlpha:0];
    [self.altTextBackgroundView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.altTextBackgroundView];
    
    self.altTextScrollView = [[UIScrollView alloc] init];
    [self.altTextScrollView setAlpha:0];
    [self.view addSubview:self.altTextScrollView];
    
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
    
    // Setup controls
    [self.controlsViewCanvas setAlpha:0];
    
    // Setup gesture recognisers
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    // Setup gesture recognisers
    self.lastTimeOverlaysToggled = 0;
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTapRecognizer];
    
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

- (void)configureView
{
    DataViewController *this = self;
    self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    UIImage *placeHolderImage = [UIImage imageNamed:@"terrible_small_logo"];
    
    CGSize imageSize;
    imageSize = CGSizeMake(placeHolderImage.size.width, placeHolderImage.size.height);
    self.scrollView.contentSize = imageSize;
    [self.imageView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    self.imageView.center = CGPointMake((self.scrollView.bounds.size.width/2),(self.scrollView.bounds.size.height/2));

    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[self.dataObject imageURL]] placeholderImage:placeHolderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
        
        // Set the content view to be the size of the comid image size
        CGSize comicSize;
        NSInteger scale = 1;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            // Retina display
            scale = 2;
        }
        
        comicSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
        
        self.scrollView.contentSize = comicSize;
        
        // If gif, start animating
        NSString *urlString = [[self.dataObject imageURL] absoluteString];
        if ([@"gif" isEqualToString:[urlString substringFromIndex:[urlString length]-3]]) {
            // FIXME: Would be good if we could set the proper duration, not just make one up
            // Should also refactor and move this outside the AFNetworking code, so we don't fetch it twice
            image = [UIImage animatedImageWithAnimatedGIFURL:[self.dataObject imageURL] duration:30];
        }
        
        [self.imageView setFrame:CGRectMake(0, 0, comicSize.width, comicSize.height)];
        [self.imageView setImage:image];
        
        self.imageView.center = CGPointMake((self.scrollView.bounds.size.width/2),(self.scrollView.bounds.size.height/2));
        
        // Fade out the title if it's covering the image
        self.shouldHideTitle = (self.imageView.frame.origin.y < self.titleLabel.frame.size.height);
        if (self.shouldHideTitle) {
            [UIView animateWithDuration:2+pageOverlayToggleAnimationTime
                             animations:^{self.titleLabel.alpha = 0;}
                             completion:nil];            
        }
        
        [this checkLoadedState];
        
    } failure:nil];
    
    self.titleLabel.text = [self.dataObject safeTitle];
    
    // Setup the alt text view
    // CGSize partialStringSize  = [partialString sizeWithFont:label.font constrainedToSize:sizeForText lineBreakMode:label.lineBreakMode];
    NSString *altText = [[self dataObject] alt];
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *labelFont = [UIFont systemFontOfSize:17];
    [self.altTextView setText:altText];
    [self.altTextView setFont:labelFont];
    [self.altTextView setLineBreakMode:lineBreakMode];
    
    float titleBarHeight = self.titleLabel.frame.size.height;
    float maxWidthForAltText  = self.view.bounds.size.width - 2*altTextBackgroundPadding - 2*altTextPadding;
    float maxHeightForAltText = self.view.bounds.size.height - 2*altTextBackgroundPadding - 2*altTextPadding - titleBarHeight;
    
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
    
    // Check segment state
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
    
    int latestPage = [[NSUserDefaults standardUserDefaults] integerForKey:UserDefaultLatestPage];
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

- (void)toggleTitleAndAltText
{
    if ([self.altTextBackgroundView alpha] == 0) {
        [self.scrollView setScrollEnabled:NO];
        
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.altTextBackgroundView.alpha = 0.8;}
                         completion:nil];
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.altTextScrollView.alpha = 0.8;}
                         completion:nil];
        if (self.shouldHideTitle) {
            [UIView animateWithDuration:pageOverlayToggleAnimationTime
                             animations:^{self.titleLabel.alpha = 0.8;}
                             completion:nil];
        }
    } else {
        [self.scrollView setScrollEnabled:YES];
        
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.altTextBackgroundView.alpha = 0;}
                         completion:nil];
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.altTextScrollView.alpha = 0;}
                         completion:nil];
        if (self.shouldHideTitle) {
            [UIView animateWithDuration:pageOverlayToggleAnimationTime
                             animations:^{self.titleLabel.alpha = 0;}
                             completion:nil];
        }
    }
}

- (void)toggleControls
{
    if ([self.controlsViewCanvas alpha] == 0) {
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.controlsViewCanvas.alpha = 1.0;}
                         completion:nil];
    } else {
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.controlsViewCanvas.alpha = 0;}
                         completion:nil];
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

@end
