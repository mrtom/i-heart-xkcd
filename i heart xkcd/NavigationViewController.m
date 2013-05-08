//
//  NavigationViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 05/02/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "NavigationViewController.h"

#import "ComicStore.h"
#import "Constants.h"
#import "DataViewController.h"
#import "ModelController.h"
#import "Settings.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

@synthesize delegate;

- (id)init
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self = [super initWithNibName:@"NavigationViewController_iPad" bundle:nil];
    } else {
        self = [super initWithNibName:@"NavigationViewController_iPhone" bundle:nil];
    }
    
    if (self) {
        self.title = NSLocalizedString(@"Navigate", @"Navigate");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setAlpha:0];
    
    [self.favouritePickerView setDelegate:self];
    [self.favouritePickerView setDataSource:[ComicStore sharedStore]];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentComic:(NSInteger)index
{
    _currentComic = index;
    [self configureSegmentedControlsState];
}

- (void)configureSegmentedControlsState
{
    if (self.currentComic == 1 || self.currentComic == 0) {
        if (self.controlsViewSegmentEnds) [self.controlsViewSegmentEnds setEnabled:NO forSegmentAtIndex:0];
        if (self.controlsViewNextRandom)  [self.controlsViewNextRandom setEnabled:NO forSegmentAtIndex:0];
        if (self.controlsViewSegmentAll) {
            [self.controlsViewSegmentAll setEnabled:NO forSegmentAtIndex:0];
            [self.controlsViewSegmentAll setEnabled:NO forSegmentAtIndex:1];
        }
    } else {
        if (self.controlsViewSegmentEnds) [self.controlsViewSegmentEnds setEnabled:YES forSegmentAtIndex:0];
        if (self.controlsViewNextRandom)  [self.controlsViewNextRandom setEnabled:YES forSegmentAtIndex:0];
        if (self.controlsViewSegmentAll) {
            [self.controlsViewSegmentAll setEnabled:YES forSegmentAtIndex:0];
            [self.controlsViewSegmentAll setEnabled:YES forSegmentAtIndex:1];
        }
    }
    
    int latestPage = [[NSUserDefaults standardUserDefaults] integerForKey:iheartxkcd_UserDefaultLatestPage];
    if (self.currentComic == latestPage) {
        if (self.controlsViewSegmentEnds) [self.controlsViewSegmentEnds setEnabled:NO forSegmentAtIndex:1];
        if (self.controlsViewNextRandom)  [self.controlsViewNextRandom setEnabled:NO forSegmentAtIndex:2];
        if (self.controlsViewSegmentAll) {
            [self.controlsViewSegmentAll setEnabled:NO forSegmentAtIndex:3];
            [self.controlsViewSegmentAll setEnabled:NO forSegmentAtIndex:4];
        }
    } else {
        if (self.controlsViewSegmentEnds) [self.controlsViewSegmentEnds setEnabled:YES forSegmentAtIndex:1];
        if (self.controlsViewNextRandom)  [self.controlsViewNextRandom setEnabled:YES forSegmentAtIndex:2];
        if (self.controlsViewSegmentAll) {
            [self.controlsViewSegmentAll setEnabled:YES forSegmentAtIndex:3];
            [self.controlsViewSegmentAll setEnabled:YES forSegmentAtIndex:4];
        }
    }
}

- (BOOL)isShowingControls
{
    return self.view.alpha == 1.0;
}

- (void)showControls
{
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{self.view.alpha = 1.0;}
                     completion:nil];
}

- (void)hideControls
{
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{self.view.alpha = 0;}
                     completion:nil];
}

- (void)reloadFavourites
{
    // FIXME: This would probably be better done using pub/sub
    [self.favouritePickerView reloadData];
}

#pragma mark - Comic control
-(IBAction)controlsViewSegmentAllIndexChanged
{
    switch (self.controlsViewSegmentAll.selectedSegmentIndex) {
        case 0:
            [self goFirst];
            break;
        case 1:
            [self goPrevious];
            break;
        case 2:
            [self goRandom];
            break;
        case 3:
            [self goNext];
            break;
        case 4:
            [self goLast];
            break;
    }
    [self.controlsViewSegmentAll setSelectedSegmentIndex:UISegmentedControlNoSegment];
}
-(IBAction)controlsViewSegmentEndsIndexChanged
{
    switch (self.controlsViewSegmentEnds.selectedSegmentIndex) {
        case 0:
            [self goFirst];
            break;
        case 1:
            [self goLast];
            break;
    }
    [self.controlsViewSegmentEnds setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

-(IBAction)controlsViewNextRandomIndexChanged
{
    switch (self.controlsViewNextRandom.selectedSegmentIndex) {
        case 0:
            [self goPrevious];
            break;
        case 1:
            [self goRandom];
            break;
        case 2:
            [self goNext];
            break;
    }
    [self.controlsViewNextRandom setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

- (void)goFirst
{
    [self.delegate loadFirstComic];
}

- (void)goLast
{
    [self.delegate loadLastComic];
}

- (void)goPrevious
{
    [self.delegate loadPreviousComic];
}

- (void)goRandom
{
    [self.delegate loadRandomComic];
}

- (void)goNext
{
    [self.delegate loadNextComic];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ComicStore *store = [ComicStore sharedStore];
    NSArray *comics = [store favouriteComicsByKey];
    ComicData *comicForRow = [store comicForKey:[comics objectAtIndex:[indexPath row]]];
    
    [self.delegate loadComicAtIndex:[comicForRow comicID]];
}

@end
