//
//  SearchViewControllerProtocol.h
//  i heart xkcd
//
//  Created by Tom Elliott on 16/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchViewControllerProtocol <NSObject>

@required
- (void)loadComicAtIndex:(NSInteger)index;

@end