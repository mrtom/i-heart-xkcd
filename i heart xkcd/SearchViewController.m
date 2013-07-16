//
//  SearchViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "SearchViewController.h"

#import "SearchRequest.h"

#define TITLE_KEY @"safe_title"
#define ID_KEY @"num"

@interface SearchViewController ()

@property (strong, nonatomic) SearchRequest *searchRequest;
@property (strong, nonatomic) NSArray *searchResults;

@end

@implementation SearchViewController

@synthesize searchBar, resultsTable, recentSearchesController, recentSearchesPopoverController, noResultsLabel, activitySpinner;

#pragma mark Create and manage the search results controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Search");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.searchResults = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.searchRequest = [[SearchRequest alloc] init];
    
    // Create and configure a search bar.
    searchBar.delegate = self;
    searchBar.showsBookmarkButton = NO;
    searchBar.showsCancelButton = NO;
    searchBar.tintColor = [UIColor blackColor];
    
    [resultsTable setDataSource:self];
    [resultsTable setDelegate:self];
    [noResultsLabel setAlpha:0.0f];
    [activitySpinner setAlpha:0.0f];
    
    // Create and configure the recent searches controller.
    recentSearchesController = [[RecentSearchesController alloc] initWithStyle:UITableViewStylePlain];
    recentSearchesController.delegate = self;
    
    // note: the UIPopoverController will be created later on demand, if required
    
    // Add gesture recognizers
    UITapGestureRecognizer *tableViewGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTapped:)];
    [tableViewGR setNumberOfTapsRequired:1];
    [resultsTable addGestureRecognizer:tableViewGR];
}

- (void)finishSearchWithString:(NSString *)searchString {
    
    if ([self deviceSupportsPopovers]) {
        [recentSearchesPopoverController dismissPopoverAnimated:YES];
        self.recentSearchesPopoverController = nil;        
    }
    
    [noResultsLabel setAlpha:0.0f];
    [activitySpinner setAlpha:1.0f];
    [activitySpinner startAnimating];
    
    [self.searchRequest searchWithQuery:searchString success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self handleValidResult:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self handleErrorResult:JSON];
    }];
    
    [searchBar resignFirstResponder];
}

- (void)handleValidResult:(id)JSON
{
    [activitySpinner setAlpha:0.0f];
    [self.noResultsLabel setAlpha:0.0f];
    [self.resultsTable setAlpha:1.0f];
    
    self.searchResults = JSON;
    
    [resultsTable reloadData];
    
    if ([self.searchResults count] == 0) {
        [self.noResultsLabel setText:@"No Results"];
        [self.noResultsLabel setAlpha:1.0f];
        [self.resultsTable setAlpha:0.0f];
    }
}

- (void)handleErrorResult:(id)JSON
{
    [activitySpinner setAlpha:0.0f];
    [self.noResultsLabel setText:@"Error searching"];
    [self.noResultsLabel setAlpha:1.0f];
    [self.resultsTable setAlpha:0.0f];
}

#pragma mark - Gesture Recognizers
- (void)tableTapped:(UIGestureRecognizer *) sender
{
    [self.searchBar resignFirstResponder];
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
    
    if ([searchText length] == 0) {
        self.searchResults = [[NSArray alloc] init];
        [resultsTable reloadData];
    }
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
    
    NSInteger row = [indexPath row];
    NSString *title = [[self.searchResults objectAtIndex:row] valueForKeyPath:TITLE_KEY];
    NSString *comic_id = [[self.searchResults objectAtIndex:row] valueForKeyPath:ID_KEY];
    [cell.textLabel setText:[NSString stringWithFormat:@"#%@: %@", comic_id, title]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSString* comic_id = [[self.searchResults objectAtIndex:row] valueForKeyPath:ID_KEY];
    [self.delegate loadComicAtIndex:[comic_id integerValue]];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
