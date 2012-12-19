//
//  ComicImageStoreController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 18/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "ComicImageStoreController.h"

#import "Settings.h"

@interface ComicImageStoreController ()
@property NSUInteger maxSize;
@end

@implementation ComicImageStoreController

@synthesize maxSize;

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (ComicImageStoreController *)sharedStore
{
    static ComicImageStoreController *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setMaxSize:[Settings maxCacheSize]];
        
        store = [[NSMutableDictionary alloc] initWithCapacity:self.maxSize];
        favouriteStore = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}

- (void)pushComic:(ComicData *)comic withImage:(UIImage *)comicImage
{
    // Our stores links the filename to the time it was added
    NSNumber *addDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];

    // First, check if comic is favourite and if we're caching all favourites
    if ([comic isFavourite] && [Settings shouldCacheFavourites]) {
        [favouriteStore setObject:addDate forKey:[self keyForComic:comic]];
    } else {
        // Otherwise, place in the default store
        while ([store count] > maxSize) {
            NSArray *sortedKeys = [store keysSortedByValueUsingSelector:@selector(compare:)];
            [self deleteImageFromDiskWithKey:[sortedKeys objectAtIndex:0]];
        }

        [store setObject:addDate forKey:[self keyForComic:comic]];
    }
    
    // Save the image to disk
    NSString *imagePath = [self imagePathForComic:comic];
    NSLog(@"Writing image to %@", imagePath);
    NSData *d = UIImageJPEGRepresentation(comicImage, 0.5);
    
    NSError *error;
    BOOL didWrite = [d writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    if (!didWrite) {
        NSLog(@"TODO: Didn't write image to disk. Do something about this");
        NSLog(@"Error returned was %@", error);
    }
}

- (UIImage *)imageForComic:(ComicData *)comic
{
    NSString *imagePath = [self imagePathForComic:comic];
    
    NSLog(@"%@", imagePath);
    UIImage *cachedImage = [UIImage imageWithContentsOfFile:imagePath];
    
    if (cachedImage) {
        return cachedImage;
    }

    return Nil;
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (NSString *)imagePathForComic:(ComicData *)comic
{
    return [self imagePathForKey:[self keyForComic:comic]];
}

- (NSString *)keyForComic:(ComicData *)comic
{
    return [NSString stringWithFormat:@"%d", [comic comicID]];
}

- (void)deleteImageFromDiskForComic:(ComicData *)comic
{
    [self deleteImageFromDiskWithKey:[self keyForComic:comic]];
}

- (void)deleteImageFromDiskWithKey:(NSString *)key
{
    if (!key) return;
    
    [store removeObjectForKey:key];
    [favouriteStore removeObjectForKey:key];
    
    NSString *path = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"Flushing %d images out of the cache", [store count]);
    // Iterate over the array and remove all the images
    for (id key in store) {
        [self deleteImageFromDiskWithKey:key];
    }
    
    for (id key in favouriteStore) {
        [self deleteImageFromDiskWithKey:key];
    }
}

@end
