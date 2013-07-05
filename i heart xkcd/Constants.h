//
//  Constants.h
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#define pageOverlayToggleAnimationTime 0.300
#define pageOverlayToggleBounceLimit pageOverlayToggleAnimationTime+0.025

#define altViewBackgroundColor [UIColor blackColor]
#define translutentAlpha 0.8

#define altTextBackgroundPadding 15           // Padding between the alt text background and the parent view
#define altTextPadding 10                     // Padding between the alt text and the alt text background
#define favouriteAndFacebookButtonSide 52
#define comicPadding altTextBackgroundPadding // Padding between the scroll view housing the comic and the parent view

#define comicIsFavouriteBackgroundImage @"heart"
#define comicIsNotFavouriteBackgroundImage @"heart_add"
#define isLoggedIntoFacebookBackgroundImage @"f_logo"
#define isNotLoggedIntoFacebookBackgroundImage @"f_logo_disabled"

#define ComicLoadedAtIndexNotificationName @"comicLoadedAtIndex"
#define ComicLoadedAtIndexNotificationIndexKey @"index"
#define ComicLoadedAtIndexNotificationDataKey @"data"

#define FavouritesSetUpdated @"favouritesSetUpdated"

@end
