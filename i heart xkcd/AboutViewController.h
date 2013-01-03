//
//  AboutViewController.h
//  i heart xkcd
//
//  Created by Tom Elliott on 03/01/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *aboutXkcdTitle;
@property (strong, nonatomic) IBOutlet UITextView *aboutXkcdBody;
@property (strong, nonatomic) IBOutlet UILabel *aboutIHeartXkcdTitle;
@property (strong, nonatomic) IBOutlet UITextView *aboutIHeartXkcdBody;

@end
