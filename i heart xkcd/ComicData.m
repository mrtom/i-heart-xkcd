//
//  CartoonData.m
//  i heart xkcd
//
//  Created by Tom Elliott on 12/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "ComicData.h"

#import "ComicStore.h"

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
@synthesize isFavourite = _isFavourite;

- (id)init
{
    self = [super init];
    if (self) {
        [self setIsLoaded:NO];
        [self setIsFavourite:NO];
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

- (id)initWithIndex:(NSUInteger)index
{
    self = [self init];
    if (self) {
        // Setup a blank comic
        [self setDay:NSNotFound];
        [self setMonth:NSNotFound];
        [self setYear:NSNotFound];
        
        [self setComicID:index];
        
        [self setLink:@""];
        [self setNews:@""];
        [self setTitle:@" "];
        [self setSafeTitle:@""];
        [self setTranscript:@""];
        [self setAlt:@""];
        [self setImageURL:Nil];        
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

- (NSString *)description
{
    NSString *descriptionString =
    [[NSString alloc] initWithFormat:@"%d (%@)",
     _comicID,
     [_imageURL absoluteString]];

    return descriptionString;
}

#pragma mark - NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setDay:[aDecoder decodeIntForKey:@"day"]];
        [self setMonth:[aDecoder decodeIntForKey:@"month"]];
        [self setYear:[aDecoder decodeIntForKey:@"year"]];
        
        [self setComicID:[aDecoder decodeIntForKey:@"num"]];
        
        [self setLink:[aDecoder decodeObjectForKey:@"link"]];
        [self setNews:[aDecoder decodeObjectForKey:@"news"]];
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setSafeTitle:[aDecoder decodeObjectForKey:@"safe_title"]];
        [self setTranscript:[aDecoder decodeObjectForKey:@"transcript"]];
        [self setAlt:[aDecoder decodeObjectForKey:@"alt"]];
        [self setImageURL:[NSURL URLWithString:[aDecoder decodeObjectForKey:@"img"]]];
        
        [self setIsLoaded:[aDecoder decodeBoolForKey:@"is_loaded"]];
        [self setIsFavourite:[aDecoder decodeBoolForKey:@"is_favourite"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_day forKey:@"day"];
    [aCoder encodeInt:_month forKey:@"month"];
    [aCoder encodeInt:_year forKey:@"year"];
    
    [aCoder encodeInt:_comicID forKey:@"num"];
    
    [aCoder encodeObject:_link forKey:@"link"];
    [aCoder encodeObject:_news forKey:@"news"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_safeTitle forKey:@"safe_title"];
    [aCoder encodeObject:_transcript forKey:@"transcript"];
    [aCoder encodeObject:_alt forKey:@"alt"];
    [aCoder encodeObject:[_imageURL absoluteString] forKey:@"img"];
    
    [aCoder encodeBool:_isLoaded forKey:@"is_loaded"];
    [aCoder encodeBool:_isFavourite forKey:@"is_favourite"];
}

- (NSComparisonResult)compare:(ComicData*)aComic
{
    NSInteger myId = [self comicID];
    NSInteger theirId = [aComic comicID];
    
    if (myId > theirId) return NSOrderedDescending;
    if (theirId > myId) return NSOrderedAscending;
    
    return NSOrderedSame;
}

@end
