//
//  DataViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "DataViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DataViewController ()

@property UIImageView *imageView;

@end

@implementation DataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] init];
    
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.contentSize = CGSizeMake(768,1024);
    self.scrollView.delegate=self;
    
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
    [self configureView];
}

- (void)configureView
{
    self.titleLabel.text = [self.dataObject title];
    
    [self.imageView setImageWithURL:[self.dataObject imageURL] placeholderImage:[UIImage imageNamed:@"terrible_small_logo"]];
    // UIImage *image = [UIImage imageNamed:@"terrible_small_logo"];
    // [self.imageView setImage:image];
    [self.imageView setFrame:CGRectMake(0, 0, 768, 1024)];
    
    // NSLog(@"%f, %f", image.size.width, image.size.height);
    // self.scrollView.contentSize = CGSizeMake(image.size.height, image.size.width);
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
