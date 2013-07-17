//
//  ModelController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "ModelController.h"

#import <AFNetworking/AFNetworking.h>

#import "ComicData.h"
#import "ComicStore.h"
#import "DataViewController.h"

#define ModelControllerFrontPageID 0

/*
 
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
@property (weak, nonatomic) ComicStore *comicStore;
@end


@implementation ModelController

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.comicStore = [ComicStore sharedStore];
        
        int lP = [[NSUserDefaults standardUserDefaults] integerForKey:iheartxkcd_UserDefaultLatestPage];
        _latestPage = lP;
        
        int lUT = [[NSUserDefaults standardUserDefaults] integerForKey:iheartxkcd_UserDefaultLastUpdate];
        _lastUpdateTime = lUT;
        
        // Setup the cover page
        ComicData *frontPage = [[ComicData alloc] init];
        
        [frontPage setDay:NSNotFound];
        [frontPage setMonth:NSNotFound];
        [frontPage setYear:NSNotFound];
        
        [frontPage setComicID:ModelControllerFrontPageID];
        
        [frontPage setLink:@""];
        [frontPage setNews:@""];
        [frontPage setTitle:@"i heart xkcd"];
        [frontPage setSafeTitle:@"i heart xkcd"];
        [frontPage setTranscript:@""];
        [frontPage setAlt:@""];
        [frontPage setImageURL:Nil];
        
        [frontPage setIsLoaded:YES];
        
        [self.comicStore addComic:frontPage];
        
        // Setup the 404 page
        [self add404];
        
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
        
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:iheartxkcd_UserDefaultLatestPage];
        [[NSUserDefaults standardUserDefaults] setInteger:self.lastUpdateTime forKey:iheartxkcd_UserDefaultLastUpdate];

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
        ComicData *comicData = [self.comicStore comicForKey:[JSON valueForKeyPath:@"num"]];
        NSString *index = [NSString stringWithFormat:@"%@", [JSON valueForKeyPath:@"num"]];
        if (!comicData) {
            comicData = [[ComicData alloc] initWithJSON:JSON];
            [self.comicStore addComic:comicData];
            BOOL saved = [self.comicStore saveChanges];
            if (!saved) {
                NSLog(@"TODO: Cache not working. Make sure I know about this at some point");
            }
        } else {
            [comicData updateDataWithValuesFromAPI:JSON];
        }
        callback([index integerValue], comicData);
    } failure:nil];
    
    [operation start];
}

- (NSUInteger)indexOfLastComic
{
    return self.latestPage;
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
    ComicData *comicData = [self.comicStore comicForKey:key];
    if (!comicData || ![comicData isLoaded]) {
        [self configureComicDataFromXkcdForComidID:index withCallback:^(NSUInteger index, ComicData *newComicData){
            [dataViewController setDataObject:newComicData];
        }];
        comicData = [[ComicData alloc]initWithIndex:index];
        [self.comicStore addComic:comicData];
    }
    
    dataViewController.dataObject = comicData;
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DataViewController *)viewController
{
    return viewController.dataObject.comicID;
}

- (void)add404
{
    ComicData *fourOhfourPage = [[ComicData alloc] init];
    
    [fourOhfourPage setDay:NSNotFound];
    [fourOhfourPage setMonth:NSNotFound];
    [fourOhfourPage setYear:NSNotFound];
    
    [fourOhfourPage setComicID:404];
    
    [fourOhfourPage setLink:@""];
    [fourOhfourPage setNews:@""];
    [fourOhfourPage setTitle:@"[Not Found]"];
    [fourOhfourPage setSafeTitle:@"[Not Found]"];
    [fourOhfourPage setTranscript:@""];
    [fourOhfourPage setAlt:@"Not Found"];
    [fourOhfourPage setImageURL:Nil];
    
    [fourOhfourPage setIsLoaded:YES];
    
    [self.comicStore addComic:fourOhfourPage];
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
    if (index == [[self.comicStore allComics] count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
