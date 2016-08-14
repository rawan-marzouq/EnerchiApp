//
//  DisaggregationViewController.m
//  emPower App
//
//  Created by Rawan on 1/22/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "DisaggregationViewController.h"
#import "SWRevealViewController.h"
#import "DisaggregationTextDetailsViewController.h"
#import "DisaggregationBarChartViewController.h"


@interface DisaggregationViewController ()

@end

@implementation DisaggregationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // set menu button action
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    
    // set view gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    // set header title
    UILabel *navTitleView = (UILabel *)self.navigationItem.titleView;
    if (!navTitleView) {
        navTitleView = [[UILabel alloc] initWithFrame:CGRectZero];
        navTitleView.backgroundColor = [UIColor clearColor];
        navTitleView.font = [UIFont boldSystemFontOfSize:22.0];
        navTitleView.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = navTitleView;
    }
    navTitleView.text = @"Disaggregation";
    [navTitleView sizeToFit];
    // set UIPageViewController
    [self setPageViewController];
    // add pie chart
    [self addPieChart];
}
-(void)viewDidAppear:(BOOL)animated
{
    // reload pie chart data
    [self.pieChartView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Pie Chart
-(void)addPieChart
{
    // add pie chart
    [self.pieChartView setDataSource:self];
    [self.pieChartView setDelegate:self];
    [self.pieChartView setPieCenter:CGPointMake(144, 105)];
    [self.pieChartView setStartPieAngle:M_PI_2];
    [self.pieChartView setPieBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [self.pieChartView setAnimationSpeed:1.0];
    self.pieChartView.showLabel = YES;
    [self.pieChartView setShowPercentage:YES];
    [self.pieChartView setUserInteractionEnabled:YES];
    
    // pie chart slices colors
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:51.0f/255.0f green:179.0f/255.0f blue:104.0f/255.0f alpha:1.0f],// light green
                       [UIColor colorWithRed:46.0f/255.0f green:126.0f/255.0f blue:71.0f/255.0f alpha:1.0f],// Green
                       [UIColor colorWithRed:28.0f/255.0f green:67.0f/255.0f blue:42.0f/255.0f alpha:1.0f],// Dark green
                       nil];
    // pie chart data
    self.slices = [NSMutableArray arrayWithCapacity:3];
    // dummy data
    for(int i = 0; i < 3; i ++)
    {
        NSNumber *value = [NSNumber numberWithInt:rand()%60+20];
        [_slices addObject:value];
    }
    // pie chart center label
    [self.centerLabel.layer setCornerRadius:65];
}
#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return [self.slices count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index]floatValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %lu",(unsigned long)index);
}

#pragma mark - UIPageViewController
-(void)setPageViewController
{
    UIPageViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier: @"PageController"];
    pageController.dataSource = self;
    NSArray *firstVC = @[[self itemControllerForIndex: 0]];
    [pageController setViewControllers: firstVC
                             direction: UIPageViewControllerNavigationDirectionForward
                              animated: NO
                            completion: nil];
    
    self.pageViewController = pageController;
    self.pageViewController.view.frame = CGRectMake(0, 0, self.detailsView.frame.size.width, self.detailsView.frame.size.height);
    [self addChildViewController: self.pageViewController];
    [self.detailsView addSubview: self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController: self];
    [self setupPageControl];
    
}

- (void) setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor: [UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor: [UIColor colorWithRed:23.0f/255.0f green:127.0f/255.0f blue:53.0f/255.0f alpha:1.0f]];//green
    [[UIPageControl appearance] setBackgroundColor: [UIColor clearColor]];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerBeforeViewController:(UIViewController *) viewController
{
    if(self.index == 0) {
        return nil;
    }
    
    self.index--;
    return [self itemControllerForIndex:self.index];
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerAfterViewController:(UIViewController *) viewController
{
    
    if(self.index == 1) {
        return nil;
    }
    
    self.index++;
    return [self itemControllerForIndex:self.index];
    
}

- (UIViewController *) itemControllerForIndex: (NSUInteger) itemIndex
{
    
    switch (itemIndex) {
        case 0:
        {
            DisaggregationTextDetailsViewController *textVC = [self.storyboard instantiateViewControllerWithIdentifier: @"textDetailsView"];
            return textVC;
        }
            break;
        case 1:
        {
            DisaggregationBarChartViewController *barChartVC = [self.storyboard instantiateViewControllerWithIdentifier: @"barChartView"];
            return barChartVC;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

#pragma mark - Page Indicator

- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController
{
    return 2;
}

- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController
{
    return 0;
}


@end
