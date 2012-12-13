//
//  CartoonData.m
//  i heart xkcd
//
//  Created by Tom Elliott on 12/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "ComicData.h"

@implementation ComicData

@synthesize day = _day;
@synthesize month = _month;
@synthesize year = _year;

@synthesize comicID = _comicID;

@synthesize link = _link;
@synthesize news = _news;
@synthesize title = _title;
@synthesize safeTitle = _safeTitle;
@synthesize transcript = _transcript;
@synthesize alt = _alt;
@synthesize imageURL = _imageURL;

@synthesize isLoaded = _isLoaded;

- (id)init
{
    self = [super init];
    if (self) {
        [self setIsLoaded:NO];
    }
    return self;
}

- (id)initWithJSON:(id)json
{
    self = [self init];
    if (self) {
        [self configureFromJSON:json];
    }
    return self;
}

- (void)updateDataWithValuesFromAPI:(id)json
{
    [self configureFromJSON:json];
}

- (void)configureFromJSON:(id)json
{
    [self setDay:[[json valueForKey:@"day"] intValue]];
    [self setMonth:[[json valueForKey:@"month"] intValue]];
    [self setYear:[[json valueForKey:@"year"] intValue]];
    
    [self setComicID:[[json valueForKey:@"num"] intValue]];
    
    [self setLink:[json valueForKey:@"link"]];
    [self setNews:[json valueForKey:@"news"]];
    [self setTitle:[json valueForKey:@"title"]];
    [self setSafeTitle:[json valueForKey:@"safe_title"]];
    [self setTranscript:[json valueForKey:@"transcript"]];
    [self setAlt:[json valueForKey:@"alt"]];
    [self setImageURL:[NSURL URLWithString:[json valueForKey:@"img"]]];
    
    [self setIsLoaded:YES];
}

@end
