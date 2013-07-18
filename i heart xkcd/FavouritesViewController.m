//
//  FavouritesViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "FavouritesViewController.h"

#import "ComicData.h"
#import "ComicStore.h"
#import "Constants.h"

@interface FavouritesViewController ()

@end

@implementation FavouritesViewController

@synthesize delegate, favouritePickerView;

- (id)init
{
    self = [super init];
    if (self) {
        self.trackedViewName = @"Favourites View Controller";
        self.title = NSLocalizedString(@"Favourites", @"Favourites");
        self.tabBarItem.image = [UIImage imageNamed:@"TabBarHeart.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    CGRect favouritesTableRect = self.view.bounds;
//    favouritesTableRect.origin.x = 20;
//    favouritesTableRect.origin.y = 20;
//    favouritesTableRect.size.height = favouritesTableRect.size.height - 40;
//    favouritesTableRect.size.width = favouritesTableRect.size.width - 40;
//    
//    self.favouritePickerView = [[UITableView alloc] initWithFrame:favouritesTableRect];
    self.favouritePickerView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [self.favouritePickerView setBackgroundColor:[UIColor clearColor]];
    [self.favouritePickerView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.favouritePickerView setSeparatorColor:[UIColor lightGrayColor]];
    
    [self.favouritePickerView setDelegate:self];
    [self.favouritePickerView setDataSource:[ComicStore sharedStore]];
    [self.view addSubview:self.favouritePickerView];
    [self.favouritePickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[favouritePickerView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(favouritePickerView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[favouritePickerView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(favouritePickerView)]];
    
    // Register interest in favourites set changing
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(reloadFavourites:) name:FavouritesSetUpdated object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadFavourites:(NSNotification*)notification
{
    [self.favouritePickerView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ComicStore *store = [ComicStore sharedStore];
    NSArray *comics = [store favouriteComicsByKey];
    ComicData *comicForRow = [store comicForKey:[comics objectAtIndex:[indexPath row]]];
    
    [self.delegate loadComicAtIndex:[comicForRow comicID]];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

@end
