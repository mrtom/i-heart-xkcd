//
//  ComicStore.h
//  i heart xkcd
//
//  Created by Tom Elliott on 19/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ComicData;

@interface ComicStore : NSObject <UITableViewDataSource>
{
    NSMutableDictionary *comicsData;
    NSMutableDictionary *favouritesData;
}

+ (ComicStore *)sharedStore;

- (NSArray *)allComics;
- (NSArray *)favouriteComicsByKey;

- (ComicData *)comicForKey:(NSString *)key;

- (void)addComic:(ComicData *)comic;
- (void)removeComic:(NSString *)key;
- (void)setAsFavourite:(ComicData *)comic;
- (void)setAsNotFavourite:(ComicData *)comic;

- (BOOL)saveChanges;
- (void)clearCache:(NSNotification *)note;

- (void)logCacheInfo;

@end
