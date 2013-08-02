//
//  AltViewControllerProtocol.h
//  i heart xkcd
//
//  Created by Tom Elliott on 19/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ComicData;

@protocol AltViewControllerProtocol <NSObject>
@required
- (ComicData *)comicData;
- (UIImageView *)comicImage;
- (CGPoint)comicOffset;
- (CGSize)comicSize;

@end
