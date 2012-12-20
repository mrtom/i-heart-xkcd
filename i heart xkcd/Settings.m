//
//  Settings.m
//  i heart xkcd
//
//  Created by Tom Elliott on 19/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "Settings.h"

@implementation Settings

// For now, we're not going to cache these. We can improve this is we need to
// but I assume that fetching them from NSUserDefaults isn't expensive

+(NSUInteger) maxCacheSize
{
    NSInteger storedValue = [[NSUserDefaults standardUserDefaults] integerForKey:UserDefaultMaxCacheSize];
    NSUInteger maxCacheSize = 0;
    
    switch(storedValue) {
        case 0:
            return 0;
        case 1:
            return 5;
        case 2:
            return 10;
        case 3:
            return 50;
        case 4:
            return 100;
        case 5:
            return 500;
        case 6:
            return NSIntegerMax;
        default:
            NSLog(@"Unrecognised value for %@. Given %d", UserDefaultMaxCacheSize, storedValue);
            return 0;
    }
    
    return maxCacheSize;
}

+(BOOL) shouldCacheFavourites
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultShouldCacheFavourites];
}

+(BOOL) shouldClearCache
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultShouldClearCache];
}

@end
