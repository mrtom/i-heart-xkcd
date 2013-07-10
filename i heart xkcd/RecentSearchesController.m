//
//  RecentSearchesController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 05/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "RecentSearchesController.h"

NSString *RecentSearchesKey = @"RecentSearchesKey";


@implementation RecentSearchesController

@synthesize delegate, recentSearches, displayedRecentSearches, clearButtonItem, confirmSheet;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Recents";
    self.contentSizeForViewInPopover = CGSizeMake(300.0, 280.0);
    
    // Set up the recent searches list, from user defaults or using an empty array.
    NSArray *recents = [[NSUserDefaults standardUserDefaults] objectForKey:RecentSearchesKey];
    if (recents) {
        self.recentSearches = recents;
        self.displayedRecentSearches = recents;
    }
    else {
        self.recentSearches = [NSArray array];
        self.displayedRecentSearches = [NSArray array];
    }
    
    // Create a button item to clear the recents list.
    UIBarButtonItem *aButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(showClearRecentsAlert:)];
    self.clearButtonItem = aButtonItem;
    
    if ([recentSearches count] == 0) {
        // Disable the button if there are no recents items.
        clearButtonItem.enabled = NO;
    }
    self.navigationItem.leftBarButtonItem = clearButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    
    // Ensure the complete list of recents is shown on first display.
    [super viewWillAppear:animated];
    self.displayedRecentSearches = recentSearches;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.recentSearches = nil;
    self.displayedRecentSearches = nil;
}


#pragma mark -
#pragma mark Managing the recents list

- (void)addToRecentSearches:(NSString *)searchString {
    
    // Filter out any strings that shouldn't be in the recents list.
    if ([searchString isEqualToString:@""]) {
        return;
    }
    
    // Create a mutable copy of recent searches and remove the search string if it's already there (it's added to the top of the list later).
    
    NSMutableArray *mutableRecents = [recentSearches mutableCopy];
    [mutableRecents removeObject:searchString];
    
    // Add the new string at the top of the list.
    [mutableRecents insertObject:searchString atIndex:0];
    
    // Update user defaults.
    [[NSUserDefaults standardUserDefaults] setObject:mutableRecents forKey:RecentSearchesKey];
    
    // Set self's recent searches to the new recents array, and reload the table view.
    self.recentSearches = mutableRecents;
    self.displayedRecentSearches = mutableRecents;
    [self.tableView reloadData];
    
    // Ensure the clear button is enabled.
    clearButtonItem.enabled = YES;
}


- (void)filterResultsUsingString:(NSString *)filterString {
    
    // If the search string is zero-length, then restore the recent searches,
    // otherwise create a predicate to filter the recent searches using the search string.
    //
    if ([filterString length] == 0) {
        self.displayedRecentSearches = recentSearches;
    }
    else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self BEGINSWITH[cd] %@", filterString];
        NSArray *filteredRecentSearches = [recentSearches filteredArrayUsingPredicate:filterPredicate];
        self.displayedRecentSearches = filteredRecentSearches;
    }
    
    [self.tableView reloadData];
}


- (void)showClearRecentsAlert:(id)sender {
    
    // If the user taps the Clear Recents button, present an action sheet to confirm.
    confirmSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear All Recents" otherButtonTitles:nil];
    [confirmSheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        // If the user chose to clear recents, remove the recents entry from user defaults,
        // set the list to an empty array, and redisplay the table view.
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:RecentSearchesKey];
        self.recentSearches = [NSArray array];
        self.displayedRecentSearches = [NSArray array];
        [self.tableView reloadData];
        clearButtonItem.enabled = NO;
    }
    self.confirmSheet = nil;
}


#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [displayedRecentSearches count];
}


// Display the strings in displayedRecentSearches.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [displayedRecentSearches objectAtIndex:indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Notify the delegate if a row is selected.
    [delegate recentSearchesController:self didSelectString:[displayedRecentSearches objectAtIndex:indexPath.row]];
}

@end
