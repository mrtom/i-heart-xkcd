//
//  FavouritesViewControllerProtocol.h
//  i heart xkcd
//
//  Created by Tom Elliott on 21/06/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FavouritesViewControllerProtocol <NSObject>

@required
- (void)loadComicAtIndex:(NSInteger)index;

@end
