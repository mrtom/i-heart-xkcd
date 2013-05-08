//
//  AltTextViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ComicData.h"

@interface AltTextViewController : UIViewController

@property (strong, nonatomic) ComicData *dataObject;
@property (weak, nonatomic) UIImageView *comicView;

- (id)initWithData: (ComicData *)dataObject forComic:(UIImageView *)comicView;

@end
