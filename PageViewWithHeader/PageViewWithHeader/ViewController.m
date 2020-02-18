//
//  ViewController.m
//  PageViewWithHeader
//
//  Created by PudgeMa on 2020/2/6.
//  Copyright © 2020 PudgeMa. All rights reserved.
//

#import "ViewController.h"
#import "MyPageHeaderView.h"

@interface ViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *pageScrollView;
@property (strong, nonatomic) UIScrollView *page1;
@property (strong, nonatomic) UIScrollView *page2;

@property (strong, nonatomic) MyPageHeaderView *headerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    const CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    const CGFloat screenHeight = CGRectGetHeight(self.view.bounds);
    const CGRect screenFrame = self.view.bounds;
    const CGFloat topHeaderHeight = 200;

    /* Horizontal Pages*/
    UIScrollView *horizontalScrollView = [[UIScrollView alloc] initWithFrame:screenFrame];
    horizontalScrollView.contentSize = CGSizeMake(screenWidth * 2, screenHeight);
    horizontalScrollView.pagingEnabled = YES;
    horizontalScrollView.bounces = NO;
    horizontalScrollView.delegate = self;
    self.pageScrollView = horizontalScrollView;
    /* ---- Page 1 */
    UIScrollView *viewInHorizontalView1 = [[UIScrollView alloc] initWithFrame:CGRectOffset(screenFrame, 0, 0)];
    if (@available(iOS 11.0, *)) {
        viewInHorizontalView1.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    viewInHorizontalView1.contentSize = CGSizeMake(screenWidth, screenHeight * 1.3);
    viewInHorizontalView1.showsVerticalScrollIndicator = NO;
    viewInHorizontalView1.contentInset = UIEdgeInsetsMake(topHeaderHeight, 0, 0, 0);
    viewInHorizontalView1.contentOffset = CGPointMake(0, -topHeaderHeight);
    UIView *indicatorView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewInHorizontalView1.contentSize.width, viewInHorizontalView1.contentSize.height / 2)];
       indicatorView1.backgroundColor = UIColor.grayColor;
    [viewInHorizontalView1 addSubview:indicatorView1];
    [horizontalScrollView addSubview:viewInHorizontalView1];
    self.page1 = viewInHorizontalView1;
    /* ---- Page 2 */
    UIScrollView *viewInHorizontalView2 = [[UIScrollView alloc] initWithFrame:CGRectOffset(screenFrame, screenWidth, 0)];
    if (@available(iOS 11.0, *)) {
        viewInHorizontalView2.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    viewInHorizontalView2.contentSize = CGSizeMake(screenWidth, screenHeight * 1.3);
    viewInHorizontalView2.showsVerticalScrollIndicator = NO;
    viewInHorizontalView2.contentInset = UIEdgeInsetsMake(topHeaderHeight, 0, 0, 0);
    viewInHorizontalView2.contentOffset = CGPointMake(0, -topHeaderHeight);
    UIView *indicatorView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewInHorizontalView2.contentSize.width, viewInHorizontalView2.contentSize.height / 2)];
    indicatorView2.backgroundColor = UIColor.yellowColor;
    [viewInHorizontalView2 addSubview:indicatorView2];
    [horizontalScrollView addSubview:viewInHorizontalView2];
    [self.view addSubview:horizontalScrollView];
    self.page2 = viewInHorizontalView2;
    /* Header View */
    MyPageHeaderView *headerView = [[MyPageHeaderView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, topHeaderHeight)];
    headerView.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.5];
    headerView.actingParentView = viewInHorizontalView1;
    [self.view addSubview:headerView];
    self.headerView = headerView;
    /* Diasble Horizontal Gesture At Header View */
    UIPanGestureRecognizer *fakeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan)];
    fakeRecognizer.delegate = self;
    [self.view addGestureRecognizer:fakeRecognizer];
}

#pragma mark - Action

- (void)pan {
    NSLog(@"pan");
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.headerView];
    CGPoint velocity = [gestureRecognizer velocityInView:self.headerView];
    return CGRectContainsPoint(self.headerView.bounds, point) && ABS(velocity.x) > ABS(velocity.y);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return otherGestureRecognizer == self.pageScrollView.panGestureRecognizer;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < CGRectGetMaxX(self.page1.bounds)) {
        self.headerView.actingParentView = self.page1;
    } else {
        self.headerView.actingParentView = self.page2;
    }
}

@end
