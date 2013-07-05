//
//  AltTextViewControllerProtocol.h
//  i heart xkcd
//
//  Created by Tom Elliott on 08/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ComicData.h"

@protocol AltTextViewControllerProtocol <NSObject>
@required
- (ComicData *)comicData;
- (UIImageView *)imageView;

@end
