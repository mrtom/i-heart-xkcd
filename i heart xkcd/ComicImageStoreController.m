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
        
        store = [NSKeyedUnarchiver unarchiveObjectWithFile:[self storeArchivePath]];
        favouriteStore = [NSKeyedUnarchiver unarchiveObjectWithFile:[self favouriteStoreArchivePath]];
        
        if (!store) {
            store = [[NSMutableDictionary alloc] initWithCapacity:self.maxSize];
        }
        if (!favouriteStore) {
            favouriteStore = [[NSMutableDictionary alloc] initWithCapacity:10];            
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    
    return self;
}

- (BOOL)pushComic:(ComicData *)comic withImage:(UIImage *)comicImage
{
    // Our stores links the filename to the time it was added
    NSNumber *addDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];

    // First, check if comic is favourite and if we're caching all favourites
    if ([comic isFavourite] && [Settings shouldCacheFavourites]) {
        // Need to remove from the general store if it exists there
        [store removeObjectForKey:[self keyForComic:comic]];
        
        // Then add to favourite store
        [favouriteStore setObject:addDate forKey:[self keyForComic:comic]];
    } else {
        // Otherwise, place in the default store
        while ([store count] > maxSize-1) {
            NSArray *sortedKeys = [store keysSortedByValueUsingSelector:@selector(compare:)];
            [self deleteImageFromDiskWithKey:[sortedKeys objectAtIndex:0]];
        }

        [store setObject:addDate forKey:[self keyForComic:comic]];
    }
    
    // Save the image to disk
    NSString *imagePath = [self imagePathForComic:comic];
    NSData *d = UIImageJPEGRepresentation(comicImage, 1.0);
    
    NSError *error;
    BOOL didWrite = [d writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    if (!didWrite) {
        NSLog(@"TODO: Didn't write image to disk. Do something about this! Error returned was %@", error);
    }
    
    BOOL didSave = [self saveChanges];
    
    return didWrite && didSave;
}

- (BOOL)removeFavourite:(ComicData *)comic
{
    UIImage *image = [self imageForComic:comic];
    
    // Remove from favourite store
    [favouriteStore removeObjectForKey:[self keyForComic:comic]];
    
    // Add to general cache, as we accessed it recently (i.e. now) :)
    BOOL pushedComic =  [self pushComic:comic withImage:image];
    
    BOOL didSave = [self saveChanges];
    
    return pushedComic && didSave;
}

- (UIImage *)imageForComic:(ComicData *)comic
{
    NSString *imagePath = [self imagePathForComic:comic];
    
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

- (NSString *)storeArchivePath
{
    return [self archivePathForStore:@"general"];
}

- (NSString *)favouriteStoreArchivePath
{
    return [self archivePathForStore:@"favourite"];
}

- (NSString *)archivePathForStore:(NSString *)storeName
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"comic_images_%@.archive", storeName]];
}

- (BOOL)saveChanges
{
    NSString *generalPath = [self storeArchivePath];
    BOOL savedGeneral = [NSKeyedArchiver archiveRootObject:store toFile:generalPath];
    
    NSString *favouritePath = [self favouriteStoreArchivePath];
    BOOL savedFavourite = [NSKeyedArchiver archiveRootObject:favouriteStore toFile:favouritePath];
    
    return (savedGeneral && savedFavourite);
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"Flushing %d images out of the general cache", [store count]);
    // Iterate over the array and remove all the images
    @synchronized (store){
        for (id key in store.allKeys) {
            [self deleteImageFromDiskWithKey:key];
        }
    }
    
    NSLog(@"Flushing %d images out of the favourite cache", [favouriteStore count]);
    @synchronized (favouriteStore) {
        for (id key in favouriteStore.allKeys) {
            [self deleteImageFromDiskWithKey:key];
        }        
    }
    
    [self saveChanges];
}

- (void)logCacheInfo
{
    NSLog(@"We have images for %d comics in the general cache", [store count]);
    NSLog(@"We have images for %d comics in the favourite cache", [favouriteStore count]);
}

- (void)defaultsChanged
{
    [self setMaxSize:[Settings maxCacheSize]];
}

@end
