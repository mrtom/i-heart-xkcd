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
    
    self.imageView = [[UIImageView alloc] init];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.scrollView];
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.delegate=self;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    [self.scrollView setScrollEnabled:YES];
    
    [self.scrollView addSubview:self.imageView];
    
    [self.view bringSubviewToFront:self.titleLabel];
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
        
        [this checkLoadedState];
        
    } failure:nil];
    
    self.titleLabel.text = [self.dataObject safeTitle];
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

#pragma mark - UIScrollViewDelegate classes
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
