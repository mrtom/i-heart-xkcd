//
//  AltTextViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "AltTextViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
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

- (id)init;
{
    self = [super init];
    if (self) {
        self.trackedViewName = @"Alt Text View Controller";
        self.title = NSLocalizedString(@"Alt Text", @"Alt Text");
        self.tabBarItem.image = [UIImage imageNamed:@"TabBarAltText.png"];
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
    [self.altTextBackgroundView setBackgroundColor:altViewBackgroundColor];
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
    [self.favouriteButtonBackground setBackgroundColor:altViewBackgroundColor];
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
    [self.facebookShareButtonBackground setBackgroundColor:altViewBackgroundColor];
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
    ComicData *dataObject = [self.delegate comicData];
    NSString *altText = [dataObject alt];
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
    
    if ([dataObject isFavourite]) {
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
        UIImageView *comicView = [self.delegate comicImage];
        ComicData *dataObject = [self.delegate comicData];
        [FBNativeDialogs presentShareDialogModallyFrom:self
                                           initialText:nil
                                                 image:[comicView image]
                                                   url:[dataObject imageURL]
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
    ComicData *dataObject = [self.delegate comicData];
    
    if ([dataObject isFavourite]) {
        [dataObject setIsFavourite:NO];
        [[ComicStore sharedStore] setAsNotFavourite:dataObject];
        
        if ([Settings shouldCacheFavourites]) {
            didSet = [imageStore removeFavourite:dataObject];
        }
        if (didSet) {
            [self.favouriteButton setBackgroundImage:[UIImage imageNamed:comicIsNotFavouriteBackgroundImage] forState:UIControlStateNormal];
        }
    } else {
        [dataObject setIsFavourite:YES];
        [[ComicStore sharedStore] setAsFavourite:dataObject];
        
        if ([Settings shouldCacheFavourites]) {
            ComicImageStore *imageStore = [ComicImageStore sharedStore];
            UIImage *image = [imageStore imageForComic:dataObject];
            didSet = [imageStore pushComic:dataObject withImage:image];
        }
        if (didSet) {
            [self.favouriteButton setBackgroundImage:[UIImage imageNamed:comicIsFavouriteBackgroundImage] forState:UIControlStateNormal];
        }
    }

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSNotification *note = [NSNotification notificationWithName:FavouritesSetUpdated object:self];
    [nc postNotification:note];
    
    // FIXME: Do this by NSNotifcationCenter instead?
    ComicStore *store = [ComicStore sharedStore];
    [store addComic:dataObject];
    [store saveChanges];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
