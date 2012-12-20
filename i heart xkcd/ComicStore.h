//
//  ComicStore.h
//  i heart xkcd
//
//  Created by Tom Elliott on 19/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ComicData;

@interface ComicStore : NSObject
{
    NSMutableDictionary *comicsData;
}

+ (ComicStore *)sharedStore;

- (NSArray *)allComics;
- (ComicData *)comicForKey:(NSString *)key;

- (void)addComic:(ComicData *)comic;
- (void)removeComic:(NSString *)key;

- (BOOL)saveChanges;
- (void)clearCache:(NSNotification *)note;

- (void)logCacheInfo;

@end
