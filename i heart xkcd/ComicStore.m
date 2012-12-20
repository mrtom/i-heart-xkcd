//
//  ComicStore.m
//  i heart xkcd
//
//  Created by Tom Elliott on 19/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "ComicStore.h"

#import "ComicData.h"

@implementation ComicStore

+ (ComicStore *)sharedStore
{
    static ComicStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *path = [self comicArchivePath];
        comicsData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!comicsData) {
            comicsData = [[NSMutableDictionary alloc] init];
        }
        
        // Handle memory warnings - clear the cache
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (NSArray *)allComics
{
    return [comicsData allValues];
}

- (ComicData *)comicForKey:(NSString *)key
{
    return [comicsData objectForKey:key];
}

- (void)addComic:(ComicData *)comic
{
    [comicsData setObject:comic forKey:[self keyForComic:comic]];
}

- (void)removeComic:(NSString *)key
{
    [comicsData removeObjectForKey:key];
}

- (NSString *)keyForComic:(ComicData *)comic
{
    return [NSString stringWithFormat:@"%d", [comic comicID]];
}

- (NSString *)comicArchivePath
{
    NSArray *documentDirectories =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"comics.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self comicArchivePath];
    return [NSKeyedArchiver archiveRootObject:comicsData toFile:path];
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"Flushing metadata for %d comics from the cache", [comicsData count]);
    [comicsData removeAllObjects];
    [self saveChanges];
}

- (void)logCacheInfo
{
    NSLog(@"We have metadata for %d comics in the cache", [[self allComics] count]);
}


@end
