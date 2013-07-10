//
//  SearchViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize searchBar, resultsTable, recentSearchesController, recentSearchesPopoverController, noResultsLabel;

#pragma mark Create and manage the search results controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Search");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];        
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Create and configure a search bar.
    searchBar.delegate = self;
    searchBar.showsBookmarkButton = NO;
    searchBar.showsCancelButton = NO;
    searchBar.tintColor = [UIColor blackColor];
    
    [resultsTable setDataSource:self];
    [noResultsLabel setAlpha:0.0f];
    
    
    //[self.view addSubview:searchBar];
    
//    // Create a bar button item using the search bar as its view.
//    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
//    // Create a space item and set it and the search bar as the items for the toolbar.
//    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
//    toolbar.items = [NSArray arrayWithObjects:spaceItem, searchItem, nil];
    
    // Create and configure the recent searches controller.
    recentSearchesController = [[RecentSearchesController alloc] initWithStyle:UITableViewStylePlain];
    recentSearchesController.delegate = self;
    
    // note: the UIPopoverController will be created later on demand, if required
}

- (void)finishSearchWithString:(NSString *)searchString {
    
    if ([self deviceSupportsPopovers]) {
        [recentSearchesPopoverController dismissPopoverAnimated:YES];
        self.recentSearchesPopoverController = nil;        
    }
    
    // TODO: For now, just reload data
    // TODO: If we get no results, show the 'no results' string
    [resultsTable reloadData];
    
    [searchBar resignFirstResponder];
}


#pragma mark -
#pragma mark Search results controller delegate method

- (void)recentSearchesController:(RecentSearchesController *)controller didSelectString:(NSString *)searchString {
    
    // The user selected a row in the recent searches list (UITableView).
    // Set the text in the search bar to the search string, and conduct the search.
    //
    searchBar.text = searchString;
    [self finishSearchWithString:searchString];
}


#pragma mark -
#pragma mark Search bar delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    
    [searchBar becomeFirstResponder];
    if (!self.view.window.isKeyWindow) {
        [self.view.window makeKeyAndVisible];
    }
    
    if ([self deviceSupportsPopovers] && recentSearchesPopoverController == nil) // create the popover if not already open
    {
        // Create a navigation controller to contain the recent searches controller,
        // and create the popover controller to contain the navigation controller.
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.recentSearchesController];
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        self.recentSearchesPopoverController = popover;
        recentSearchesPopoverController.delegate = self;
        
        // Ensure the popover is not dismissed if the user taps in the search bar.
        popover.passthroughViews = [NSArray arrayWithObject:searchBar];
        
        // Display the search results controller popover.
        [recentSearchesPopoverController presentPopoverFromRect:[searchBar bounds]
                                                         inView:searchBar
                                       permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];        
    }
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    
    // If the user finishes editing text in the search bar by, for example:
    // tapping away rather than selecting from the recents list, then just dismiss the popover
    //
    
    // dismiss the popover, but only if it's confirm UIActionSheet is not open
    //  (UIActionSheets can take away first responder from the search bar when first opened)
    //
    // the popover's main view controller is a UINavigationController; so we need to inspect it's top view controller
    //
    if ([self deviceSupportsPopovers] && recentSearchesPopoverController != nil) {
        UINavigationController *navController = (UINavigationController *)recentSearchesPopoverController.contentViewController;
        RecentSearchesController *searchesController = (RecentSearchesController *)navController.topViewController;
        if (searchesController.confirmSheet == nil)
        {
            [recentSearchesPopoverController dismissPopoverAnimated:YES];
            self.recentSearchesPopoverController = nil;
        }
    }
    [aSearchBar resignFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {    
    [recentSearchesController filterResultsUsingString:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    NSString *searchString = [searchBar text];
    [recentSearchesController addToRecentSearches:searchString];
    [self finishSearchWithString:searchString];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    noResultsLabel.text = @"Canceled a search.";
    [searchBar resignFirstResponder];
}

- (BOOL)deviceSupportsPopovers {
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
        
    [cell.textLabel setText:[NSString stringWithFormat:@"A search result for %@, %d", searchBar.text, [indexPath row]]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arc4random() % 30;
}


#pragma mark -
#pragma mark View lifecycle

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // hide the popover while rotating, but only if it's in use
    if (self.recentSearchesPopoverController)
    {
        [self.recentSearchesPopoverController dismissPopoverAnimated:NO];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // bring back the popover after rotating, but only if it's in use
    if (self.recentSearchesPopoverController)
    {
        [self.recentSearchesPopoverController presentPopoverFromRect:self.searchBar.bounds
                                                              inView:self.searchBar
                                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                                            animated:NO];
    }
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    self.recentSearchesController = nil;
    self.recentSearchesPopoverController = nil;
    
    //self.toolbar = nil;
    self.searchBar = nil;
    self.noResultsLabel = nil;
}

@end
