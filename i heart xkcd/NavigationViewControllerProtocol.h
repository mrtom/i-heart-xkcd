//
//  DataViewControlsProtocol.h
//  i heart xkcd
//
//  Created by Tom Elliott on 15/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NavigationViewControllerProtocol <NSObject>
@required
- (void)loadFirstComic;
- (void)loadLastComic;
- (void)loadPreviousComic;
- (void)loadRandomComic;
- (void)loadNextComic;
- (void)loadComicAtIndex:(NSInteger)index;
@end