//
//  AltTextViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 06/05/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ComicData.h"
#import "AltViewController.h"
#import "AltTextViewControllerProtocol.h"

@interface AltTextViewController : AltViewController

@property (strong, nonatomic) id<AltTextViewControllerProtocol> delegate;

- (id)init;

@end
