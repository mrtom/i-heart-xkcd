//
//  FavouritesViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AltViewController.h"

#import "FavouritesViewControllerProtocol.h"

@interface FavouritesViewController : AltViewController<UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *favouritePickerView;
@property (strong, nonatomic) id<FavouritesViewControllerProtocol> delegate;

- (void)reloadFavourites:(NSNotification*)notification;

@end
