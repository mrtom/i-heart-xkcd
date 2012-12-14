//
//  RootViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "RootViewController.h"

#import "ModelController.h"

#import "DataViewController.h"

#define pageCoverAnimationTime 0.3

@interface RootViewController ()
@property (readonly, strong, nonatomic) ModelController *modelController;
@property NSUInteger currentIndex;
@end

@implementation RootViewController

@synthesize modelController = _modelController;
@synthesize pageCover;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    [self.modelController setDelegate:self];
    
    int latestPage = [[NSUserDefaults standardUserDefaults] integerForKey:UserDefaultLatestPage];
    self.currentIndex = latestPage;

    DataViewController *startingViewController = [self.modelController viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    // Configure overlay
    pageCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
    pageCover.backgroundColor = [UIColor whiteColor];
    pageCover.alpha = 0.0;
    [self.view addSubview:pageCover];
}

- (void)loadPageAtIndex:(NSInteger)index
{
    DataViewController *viewController = [self.modelController viewControllerAtIndex:index storyboard:self.storyboard];
    NSArray *viewControllers = @[viewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    [UIView animateWithDuration:pageCoverAnimationTime
                     animations:^{pageCover.alpha = 0.0;}
                     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ModelController *)modelController
{
     // Return the model controller object, creating it if necessary.
     // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    pageCover.alpha = 1.0;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [UIView animateWithDuration:pageCoverAnimationTime
                     animations:^{pageCover.alpha = 0.0;}
                     completion:nil];
    
    [self loadPageAtIndex:self.currentIndex];
}

#pragma mark - UIPageViewController delegate methods


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    DataViewController *currentViewController = [[pageViewController viewControllers] objectAtIndex:0];
    self.currentIndex = [[currentViewController dataObject] comicID];
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

#pragma mark - DataViewController delegate methods
- (void) handleLatestComicLoaded:(NSInteger) index
{
    if (self.currentIndex == index) return;
    
    RootViewController *this = self;
    [UIView animateWithDuration:pageCoverAnimationTime
                     animations:^{pageCover.alpha = 1.0;}
                     completion:^(BOOL finished){
                         [this loadPageAtIndex:index];
                     }];
}

@end