//
//  RootViewController.m
//  i heart xkcd
//
//  Created by Tom Elliott on 11/12/2012.
//  Copyright (c) 2012 Tom Elliott. All rights reserved.
//

#import "RootViewController.h"

#import "ModelController.h"
#import "Constants.h"

#import "AboutViewController.h"
#import "DataViewController.h"

#import "AltTextViewController.h"
#import "AltTextViewControllerProtocol.h"
#import "FavouritesViewController.h"
#import "SearchViewController.h"
#import "NavigationViewController.h"
#import "AboutViewController.h"

#define pageCoverAnimationTime 0.3

@interface RootViewController ()

@property (readonly, strong, nonatomic) ModelController *modelController;
@property NSUInteger currentIndex;
@property DataViewController *currentViewController;
@property (readwrite, nonatomic) double lastTimeOverlaysToggled;

@end

@implementation RootViewController

@synthesize modelController = _modelController;
@synthesize pageCover;
@synthesize currentIndex = _currentIndex;

+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1], iheartxkcd_UserDefaultLatestPage,
                              [NSNumber numberWithInt:0], iheartxkcd_UserDefaultLastUpdate,
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    [self.modelController setDelegate:self];
    
    int latestPage = [[NSUserDefaults standardUserDefaults] integerForKey:iheartxkcd_UserDefaultLatestPage];
    self.currentIndex = latestPage; // Don't go via the setter here

    DataViewController *startingViewController = [self.modelController viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
    self.currentViewController = startingViewController;
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];
    
    // Configure overlay
    pageCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
    pageCover.backgroundColor = [UIColor whiteColor];
    pageCover.alpha = 0.0;
    [self.view addSubview:pageCover];
    
    // Tab Bar for navigation
    AltTextViewController *altTextViewController = [[AltTextViewController alloc] init];
    [altTextViewController setDelegate:self];
    FavouritesViewController *favouritesViewController = [[FavouritesViewController alloc] init];
    [favouritesViewController setDelegate:self];
    UIViewController *searchViewController = [[SearchViewController alloc] init];
    NavigationViewController *navigationViewController = [[NavigationViewController alloc] init];
    [navigationViewController setDelegate:self];
    UIViewController *aboutViewController = [[AboutViewController alloc] init];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[
                                              altTextViewController,
                                              favouritesViewController,
                                              searchViewController,
                                              navigationViewController,
                                              aboutViewController];
    [self.tabBarController.view setAlpha:0.0];

    // Set the tab bar frame so it doesn't overlap the title bar
    // FIXME: float titleBarHeight = self.titleLabel.frame.size.height;
    float titleBarHeight = 20;
    CGRect tabBarFrame = self.view.frame;
    tabBarFrame.origin.y = titleBarHeight;
    tabBarFrame.size.height = tabBarFrame.size.height - titleBarHeight;    
    [self.tabBarController.view setFrame:tabBarFrame];
    [self.view addSubview:self.tabBarController.view];
    
    // Setup gesture recognisers
    UITapGestureRecognizer *pageViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    pageViewTapRecognizer.numberOfTapsRequired = 1;
    pageViewTapRecognizer.numberOfTouchesRequired = 1;
    [self.pageViewController.view addGestureRecognizer:pageViewTapRecognizer];
    
    UISwipeGestureRecognizer *tabBarViewTapRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tabBarViewTapRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    tabBarViewTapRecognizer.numberOfTouchesRequired = 1;
    [self.tabBarController.view addGestureRecognizer:tabBarViewTapRecognizer];
}

- (void)loadPageAtIndex:(NSInteger)index forDirection:(UIPageViewControllerNavigationDirection) direction andAnimation:(BOOL)animated
{
    DataViewController *viewController = [self.modelController viewControllerAtIndex:index storyboard:self.storyboard];
    NSArray *viewControllers = @[viewController];
    [self.pageViewController setViewControllers:viewControllers direction:direction animated:animated completion:NULL];
    
    [UIView animateWithDuration:pageCoverAnimationTime
                     animations:^{pageCover.alpha = 0.0;}
                     completion:^(BOOL finished){
                         if (finished) {
                             [self setCurrentIndex:index];
                             self.currentViewController = viewController;
                         }
                     }];
}

- (NSUInteger)currentIndex
{
    return _currentIndex;
}

- (void)setCurrentIndex:(NSUInteger)index
{
    _currentIndex = index;

    NSNumber *indexObject = [NSNumber numberWithInt:index];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          indexObject, ComicLoadedAtIndexNotificationIndexKey,
                          self.currentViewController.dataObject, ComicLoadedAtIndexNotificationDataKey,
                          nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSNotification *note = [NSNotification notificationWithName:ComicLoadedAtIndexNotificationName object:self userInfo:data];
    [nc postNotification:note];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ModelController *)modelController
{
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
    
    [self loadPageAtIndex:self.currentIndex forDirection:UIPageViewControllerNavigationDirectionForward andAnimation:NO];
}

#pragma mark - Handle gestures and touches

- (BOOL)canToggleOverlays
{
    double timeNow = CACurrentMediaTime();
    if (timeNow - self.lastTimeOverlaysToggled < pageOverlayToggleBounceLimit) {
        return NO;
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && [self canToggleOverlays]) {
        self.lastTimeOverlaysToggled = CACurrentMediaTime();
        
        [self toggleTabBar];
        [self.currentViewController handleTap];
    }
}

- (void)toggleTabBar
{
    if ([self.tabBarController.view alpha] == 0) {
        [self showTabBar];
    } else {
        [self hideTabBar];
    }
}

- (void)showTabBar
{
    self.tabBarController.view.alpha = 0.0;
    [self.view addSubview:self.tabBarController.view];
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{
                         self.tabBarController.view.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)hideTabBar
{
    [UIView animateWithDuration:pageOverlayToggleAnimationTime
                     animations:^{
                         self.tabBarController.view.alpha = 0;
                     }
                     completion:^ (BOOL finished){
                         if (finished) {
                             [self.tabBarController.view removeFromSuperview];
                         }
                     }];
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    DataViewController *currentViewController = [[pageViewController viewControllers] objectAtIndex:0];
    [self setCurrentIndex:[[currentViewController dataObject] comicID]];
    self.currentViewController = currentViewController;
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

- (void) switchToPageViewControllerWithoutPageTurnForIndex:(NSInteger) index
{
    if (self.currentIndex == index) return;
    
    RootViewController *this = self;
    [UIView animateWithDuration:pageCoverAnimationTime
                     animations:^{pageCover.alpha = 1.0;}
                     completion:^(BOOL finished){
                         [this loadPageAtIndex:index forDirection:UIPageViewControllerNavigationDirectionForward andAnimation:NO];
                     }];
}

#pragma mark - ModelController delegate methods

- (void) handleLatestComicLoaded:(NSInteger) index
{
    [self switchToPageViewControllerWithoutPageTurnForIndex:index];
}

#pragma mark - DataViewController delegate methods

- (void)loadFirstComic
{
    [self switchToPageViewControllerWithoutPageTurnForIndex:1];
}

- (void)loadLastComic
{
    NSLog(@"Loading %d", [self.modelController indexOfLastComic]);
    [self switchToPageViewControllerWithoutPageTurnForIndex:[self.modelController indexOfLastComic]];
}

- (void)loadPreviousComic
{
    if (self.currentIndex <= 1) {
        return;
    }
    
    [self loadPageAtIndex:self.currentIndex-1 forDirection:UIPageViewControllerNavigationDirectionReverse andAnimation:YES];
}

- (void)loadRandomComic
{
    NSInteger randomIndex = arc4random() % [self.modelController indexOfLastComic];
    
    [self switchToPageViewControllerWithoutPageTurnForIndex:randomIndex];
}

- (void)loadNextComic
{
    if (self.currentIndex >= [self.modelController indexOfLastComic]) {
        return;
    }
    
    [self loadPageAtIndex:self.currentIndex+1 forDirection:UIPageViewControllerNavigationDirectionForward andAnimation:YES];
}

- (void)loadComicAtIndex:(NSInteger)index
{
    [self loadPageAtIndex:index forDirection:UIPageViewControllerNavigationDirectionForward andAnimation:NO];
    [self hideTabBar];
}

#pragma mark AltTextViewControllerProtocol methods

- (ComicData *)comicData
{
    return self.currentViewController.dataObject;
}

- (UIImageView *)imageView
{
    return self.currentViewController.imageView;
}

@end
