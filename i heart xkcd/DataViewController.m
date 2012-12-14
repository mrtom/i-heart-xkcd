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

@interface DataViewController ()

@property UIImageView *imageView;

@end

@implementation DataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // NSLog(@"ViewDidLoad");
    
    self.imageView = [[UIImageView alloc] init];
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.delegate=self;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    [self.scrollView setScrollEnabled:YES];
    
    [self.scrollView addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // NSLog(@"View size in viewWillAppear: %fx%f", self.view.frame.size.width, self.view.frame.size.height);
    // NSLog(@"Scroll view size in viewWillAppear: %fx%f", self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);

    [self configureView];
}

- (void)viewDidLayoutSubviews
{
    // NSLog(@"View size in viewDidLayoutSubviews: %fx%f", self.view.frame.size.width, self.view.frame.size.height);
    // NSLog(@"Scroll view size in viewDidLayoutSubviews: %fx%f", self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    // [self configureView];
}

- (void)configureView
{
    UIImage *placeHolderImage = [UIImage imageNamed:@"terrible_small_logo"];
    
    self.titleLabel.text = [self.dataObject safeTitle];
    CGSize imageSize;
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        imageSize = CGSizeMake(placeHolderImage.size.width, placeHolderImage.size.height);
    } else {
        imageSize = CGSizeMake(placeHolderImage.size.height, placeHolderImage.size.width);
    }
    self.scrollView.contentSize = imageSize;
    
    // NSLog(@"View size in configureView: %fx%f", self.view.frame.size.width, self.view.frame.size.height);
    // NSLog(@"Scroll view size in configureView: %fx%f", self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    
    
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[self.dataObject imageURL]] placeholderImage:placeHolderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
        
        // Set the content view to be the size of the comid image size
        CGSize comicSize;
        NSInteger scale = 1;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            // Retina display
            scale = 2;
        }
        
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            comicSize = CGSizeMake(image.size.height*scale, image.size.width*scale);
        } else {
            comicSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
        }
        
        self.scrollView.contentSize = comicSize;
        [self.imageView setFrame:CGRectMake(0, 0, comicSize.width, comicSize.height)];
        [self.imageView setImage:image];
        
        // If the image is smaller than the size of the ipad, stick it in the middle of the page
        CGFloat paddingLeft = 0;
        CGFloat paddingTop = 0;
        // NSLog(@"Scroll view size2: %fx%f", self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        // NSLog(@"Comic size: %fx%f", self.imageView.frame.size.width, self.imageView.frame.size.height);
        if (self.imageView.frame.size.width < self.scrollView.frame.size.width) {
            paddingLeft = (self.scrollView.frame.size.width - self.imageView.frame.size.width) / 2;
        }
        if (self.imageView.frame.size.height < self.scrollView.frame.size.height) {
            paddingTop = (self.scrollView.frame.size.height - self.imageView.frame.size.height) / 2;
        }
        
        CGRect insetRect = CGRectInset(self.view.bounds, paddingLeft, paddingTop);
        // NSLog(@"Setting imageview rect to %fx%f at (%f,%f)", insetRect.size.width, insetRect.size.height, insetRect.origin.x, insetRect.origin.y);
        self.imageView.frame = insetRect;
        
    } failure:nil];

    
    
    [self.imageView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    if ([self.dataObject isLoaded]) {
        [self.loadingView stopAnimating];
    } else {
        [self.loadingView startAnimating];
    }
}

- (void)setDataObject:(ComicData *)dataObject
{
    _dataObject = dataObject;
    [self configureView];
}

#pragma mark - UIScrollViewDelegate classes
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
