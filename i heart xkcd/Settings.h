//
//  Settings.h
//  i heart xkcd
//
//  Created by Tom Elliott on 19/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultMaxCacheSize @"iheartxkcd_maxCacheSize"
#define UserDefaultShouldCacheFavourites @"iheartxkcd_cacheFavourites"

@interface Settings : NSObject

+(NSUInteger) maxCacheSize;
+(BOOL) shouldCacheFavourites;

@end
