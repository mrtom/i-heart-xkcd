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

@end

@implementation DataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [self.altTextScrollView setScrollEnabled:YES];
    [self.altTextScrollView addSubview:self.altTextView];
    
    // Setup gesture recognisers
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    // Setup gesture recognisers
    self.lastTimeOverlaysToggled = 0;
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:twoFingerTapRecognizer];
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
        [self.imageView setFrame:CGRectMake(0, 0, comicSize.width, comicSize.height)];
        [self.imageView setImage:image];
        self.imageView.center = CGPointMake((self.scrollView.bounds.size.width/2),(self.scrollView.bounds.size.height/2));
        
        // Fade out the title
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.titleLabel.alpha = 0;}
                         completion:nil];
        
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
    
    float maxWidthForAltText  = self.view.bounds.size.width - 2*altTextBackgroundPadding - 2*altTextPadding;
    float maxHeightForAltText = self.view.bounds.size.height - 2*altTextBackgroundPadding - 2*altTextPadding;
    
    CGSize altTextSize = [[self.dataObject alt] sizeWithFont:labelFont forWidth:maxWidthForAltText lineBreakMode:lineBreakMode];
    
    float altTextWidth  = altTextSize.width < maxWidthForAltText ? altTextSize.width : maxWidthForAltText;
    float altTextHeight = altTextSize.height < maxHeightForAltText ? altTextSize.height : maxHeightForAltText;
    
    [self.altTextView setFrame:CGRectMake(0, 0, altTextSize.width, altTextSize.height)];
    
    [self.altTextScrollView setFrame:CGRectMake((altTextPadding+altTextBackgroundPadding),
                                          (altTextPadding+altTextBackgroundPadding),
                                          altTextWidth, altTextHeight)];
    self.altTextScrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self.altTextScrollView setContentSize:self.altTextView.bounds.size];
    
    [self.altTextBackgroundView setFrame:CGRectMake(altTextBackgroundPadding,
                                                    altTextBackgroundPadding,
                                                    altTextSize.width+2*altTextPadding, altTextSize.height+2*altTextPadding)];
    self.altTextBackgroundView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
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

- (void) handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && [self canToggleOverlays]) {
        self.lastTimeOverlaysToggled = CACurrentMediaTime();
        
        [self toggleTitleAndAltText];
    }
}

- (void) handleDoubleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && [self canToggleOverlays]) {
        self.lastTimeOverlaysToggled = CACurrentMediaTime();
        
        NSLog(@"Double tap tapped");
    }
}

- (void)toggleTitleAndAltText
{
    if ([self.altTextBackgroundView alpha] == 0) {
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.altTextBackgroundView.alpha = 0.8;}
                         completion:nil];
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.altTextScrollView.alpha = 0.8;}
                         completion:nil];
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.titleLabel.alpha = 0.8;}
                         completion:nil];
    } else {
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.altTextBackgroundView.alpha = 0;}
                         completion:nil];
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.altTextScrollView.alpha = 0;}
                         completion:nil];
        [UIView animateWithDuration:pageOverlayToggleAnimationTime
                         animations:^{self.titleLabel.alpha = 0;}
                         completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate classes
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end