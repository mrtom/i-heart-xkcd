//
//  RecentSearchesController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 05/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *RecentSearchesKey;

@class RecentSearchesController;

@protocol RecentSearchesDelegate
// Sent when the user selects a row in the recent searches list.
- (void)recentSearchesController:(RecentSearchesController *)controller didSelectString:(NSString *)searchString;
@end


@interface RecentSearchesController : UITableViewController <UIActionSheetDelegate> {
    id <RecentSearchesDelegate> delegate;
    
    NSArray *recentSearches;
    NSArray *displayedRecentSearches;
    
    UIBarButtonItem *clearButtonItem;
    
    UIActionSheet *confirmSheet;
}

@property (nonatomic, strong) id <RecentSearchesDelegate> delegate;
@property (nonatomic, strong) NSArray *recentSearches;
@property (nonatomic, strong) NSArray *displayedRecentSearches;

@property (nonatomic, strong) UIActionSheet *confirmSheet;

@property (nonatomic, strong) UIBarButtonItem *clearButtonItem;

- (void)addToRecentSearches:(NSString *)searchString;
- (void)filterResultsUsingString:(NSString *)filterString;

@end