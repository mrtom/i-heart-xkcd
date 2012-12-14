//
//  ModelController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "ModelController.h"

#import <AFNetworking/AFNetworking.h>

#import "DataViewController.h"
#import "ComicData.h"

#define ModelControllerFrontPageID 0

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 
 XKCD JSON API returns results like (without a callback specified):
 
 {
   "day": "12",
   "month": "12",
   "year": "2012",
   "num": 1146,
   "link": "",
   "news": "",
   "safe_title": "Honest",
   "transcript": "",
   "alt": "I didn't understand what you meant. I still don't. But I'll figure it out soon!",
   "img": "http:\/\/imgs.xkcd.com\/comics\/honest.png",
   "title": "Honest"
 }
 
 */

NSString *const XKCD_API = @"http://dynamic.xkcd.com/api-0/jsonp/";


@interface ModelController()
@property (nonatomic) NSInteger latestPage;
@property (nonatomic) NSInteger lastUpdateTime;
@property (readonly, strong, nonatomic) NSMutableDictionary *comicsData;
@end


@implementation ModelController

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
        NSString *path = [self itemArchivePath];
        _comicsData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_comicsData) {
            _comicsData = [[NSMutableDictionary alloc] initWithCapacity:1];            
        }
        
        _latestPage = 0;
        _lastUpdateTime = -1; // TODO: We should save this to disk and re-read
        
        // Handle memory warnings - clear the cache
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        // Setup the cover page
        ComicData *frontPage = [[ComicData alloc] init];
        
        [frontPage setDay:NSNotFound];
        [frontPage setMonth:NSNotFound];
        [frontPage setYear:NSNotFound];
        
        [frontPage setComicID:ModelControllerFrontPageID];
        
        [frontPage setLink:@""];
        [frontPage setNews:@""];
        [frontPage setTitle:@"Welcome to i heart xkcd"];
        [frontPage setSafeTitle:@""];
        [frontPage setTranscript:@""];
        [frontPage setAlt:@""];
        [frontPage setImageURL:Nil];
        
        [frontPage setIsLoaded:YES];
        
        [self.comicsData setValue:frontPage forKey:[NSString stringWithFormat:@"%d", 0]];
        
        [self configureComicDataFromXkcd];
    }
    return self;
}

// Find the latest comic and display
- (void)configureComicDataFromXkcd
{
    [self configureComicDataFromXkcdForComidID:NSNotFound withCallback:^(NSUInteger index, ComicData *newComicData){
        self.latestPage = index;
        self.lastUpdateTime = [[NSDate date] timeIntervalSince1970];

        [self.delegate handleLatestComicLoaded:index];
    }];    
}

- (void)configureComicDataFromXkcdForComidID:(NSInteger) comicID withCallback:(void (^)(NSUInteger index, ComicData *newComicData))callback
{
    NSString *comicIDPathSegment = @"";
    if (comicID != NSNotFound) {
        comicIDPathSegment = [NSString stringWithFormat:@"/%d", comicID];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@comic%@", XKCD_API, comicIDPathSegment]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        ComicData *comicData = [self.comicsData objectForKey:[JSON valueForKeyPath:@"num"]];
        NSString *index = [NSString stringWithFormat:@"%@", [JSON valueForKeyPath:@"num"]];
        if (!comicData) {
            comicData = [[ComicData alloc] initWithJSON:JSON];
            [self.comicsData setValue:comicData forKey:index];
            [self saveChanges];
        } else {
            [comicData updateDataWithValuesFromAPI:JSON];
        }
        callback([index integerValue], comicData);
    } failure:nil];
    
    [operation start];
}

- (ComicData *)generateBlankComic:(NSUInteger)index
{
    // Setup a blank comic
    ComicData *blankComicData = [[ComicData alloc] init];
    
    [blankComicData setDay:NSNotFound];
    [blankComicData setMonth:NSNotFound];
    [blankComicData setYear:NSNotFound];
    
    [blankComicData setComicID:index];
    
    [blankComicData setLink:@""];
    [blankComicData setNews:@""];
    [blankComicData setTitle:@" "];
    [blankComicData setSafeTitle:@""];
    [blankComicData setTranscript:@""];
    [blankComicData setAlt:@""];
    [blankComicData setImageURL:Nil];
    
    [blankComicData setIsLoaded:NO];
    
    return blankComicData;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    // Return the data view controller for the given index.
    if ((self.lastUpdateTime > -1 && index > self.latestPage)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    
    NSString *key = [NSString stringWithFormat:@"%d", index];
    ComicData *comicData = [self.comicsData objectForKey:key];
    if (!comicData || ![comicData isLoaded]) {
        [self configureComicDataFromXkcdForComidID:index withCallback:^(NSUInteger index, ComicData *newComicData){
            [dataViewController setDataObject:newComicData];
        }];
        comicData = [self generateBlankComic:index];
        [self.comicsData setValue:comicData forKey:key];
    }
    
    dataViewController.dataObject = comicData;
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DataViewController *)viewController
{
    return viewController.dataObject.comicID;
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"Flushing %d comics from the cache", [_comicsData count]);
    [_comicsData removeAllObjects];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"comics.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:_comicsData toFile:path];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.comicsData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
