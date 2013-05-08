//
//  AltTextViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "AltTextViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

#import "ComicImageStore.h"
#import "ComicStore.h"
#import "Constants.h"
#import "Settings.h"

@interface AltTextViewController ()

@property UIView *altTextCanvasView;
@property UIView *altTextBackgroundView;
@property UIScrollView *altTextScrollView;
@property UILabel *altTextView;

@property UIView *favouriteButtonBackground;
@property UIView *facebookShareButtonBackground;
@property UIButton *favouriteButton;
@property UIButton *facebookShareButton;

@end

@implementation AltTextViewController

- (id)initWithData: (ComicData *)dataObject forComic:(UIImageView *)comicView;
{
    self = [super init];
    if (self) {
        self.dataObject = dataObject;
        self.comicView = comicView;
        
        self.title = NSLocalizedString(@"Alt Text", @"Alt Text");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Alt text overlay
    self.altTextCanvasView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.altTextCanvasView setBackgroundColor:[UIColor clearColor]];
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
    
    // Favourite and Facebook buttons
    self.favouriteButtonBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, favouriteAndFacebookButtonSide, favouriteAndFacebookButtonSide)];
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
    [self.facebookShareButton setBackgroundImage:[UIImage imageNamed:isNotLoggedIntoFacebookBackgroundImage] forState:UIControlStateNormal];
    [self.facebookShareButton addTarget:self action:@selector(facebookShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookShareButton setUserInteractionEnabled:YES];
    [self.altTextCanvasView addSubview:self.facebookShareButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureAltTextViews];
}

-(void)configureAltTextViews
{
    NSString *altText = [self.dataObject alt];
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *labelFont = [UIFont systemFontOfSize:17];
    [self.altTextView setText:altText];
    [self.altTextView setFont:labelFont];
    [self.altTextView setLineBreakMode:lineBreakMode];
    
    float maxWidthForAltText  = self.view.bounds.size.width - 2*altTextBackgroundPadding - 2*altTextPadding;
    float maxHeightForAltText = self.view.bounds.size.height - 2*altTextBackgroundPadding - 2*altTextPadding - favouriteAndFacebookButtonSide;
    
    CGSize altTextSize = [altText sizeWithFont:labelFont constrainedToSize:CGSizeMake(maxWidthForAltText, 9999) lineBreakMode:lineBreakMode];
    
    float altTextScrollWidth = MIN(altTextSize.width, maxWidthForAltText);
    float altTextScrollHeight = MIN(altTextSize.height, maxHeightForAltText);
    
    [self.altTextView setFrame:CGRectMake(0, 0, altTextSize.width, altTextSize.height)];
    
    [self.altTextScrollView setFrame:CGRectMake((altTextPadding+altTextBackgroundPadding),
                                                (altTextPadding+altTextBackgroundPadding),
                                                altTextScrollWidth, altTextScrollHeight)];
    self.altTextScrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self.altTextScrollView setContentSize:self.altTextView.bounds.size];
    
    [self.altTextBackgroundView setFrame:CGRectMake(altTextBackgroundPadding,
                                                    (altTextBackgroundPadding),
                                                    altTextScrollWidth+2*altTextPadding, altTextScrollHeight+2*altTextPadding)];
    self.altTextBackgroundView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    // Place About, Favourite and FB Share buttons directly on top of alttextview
    CGRect altTextFrame = [self.altTextBackgroundView frame];
    CGRect favFrame = [self.favouriteButtonBackground frame];
    CGRect fbFrame = [self.facebookShareButtonBackground frame];
    
    favFrame.origin.x = altTextFrame.origin.x;
    fbFrame.origin.x = favFrame.origin.x + favouriteAndFacebookButtonSide;
    
    favFrame.origin.y = altTextFrame.origin.y - favouriteAndFacebookButtonSide;
    fbFrame.origin.y = favFrame.origin.y;
    
    [self.favouriteButtonBackground setFrame:favFrame];
    [self.facebookShareButtonBackground setFrame:fbFrame];
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

- (void)facebookShare: (id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [FBNativeDialogs presentShareDialogModallyFrom:self
                                           initialText:nil
                                                 image:[self.comicView image]
                                                   url:[self.dataObject imageURL]
                                               handler:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login Needed" message:@"You must log into Facebook in your settings before you can post to Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
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
            // FIXME: Need to pub/sub this
            //didSet = [imageStore pushComic:self.dataObject withImage:[self.imageView image]];
        }
        if (didSet) {
            [self.favouriteButton setBackgroundImage:[UIImage imageNamed:comicIsFavouriteBackgroundImage] forState:UIControlStateNormal];
        }
    }
    // FIXME: Need to pub/sub this
    //[self.navViewController reloadFavourites];
    
    ComicStore *store = [ComicStore sharedStore];
    [store addComic:self.dataObject];
    [store saveChanges];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
