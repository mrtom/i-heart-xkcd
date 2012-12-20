//
//  ComicImageStoreController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 18/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ComicData.h"

@interface ComicImageStoreController : NSObject
{
    NSMutableDictionary *store;
    NSMutableDictionary *favouriteStore;
}
+ (ComicImageStoreController *)sharedStore;

- (BOOL)pushComic:(ComicData *)comic withImage:(UIImage *)comicImage;
- (BOOL)removeFavourite:(ComicData *)comic;

- (UIImage *)imageForComic:(ComicData *)comic;
- (NSString *)imagePathForComic:(ComicData *)comic;

- (void)clearCache:(NSNotification *)note;

- (void)logCacheInfo;

@end
