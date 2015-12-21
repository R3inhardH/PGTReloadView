//
//  ViewController.m
//  PGTReloadView
//
//  Created by Reinhard on 15/12/15.
//  Copyright © 2015 PGIT. All rights reserved.
//

#import "ViewController.h"


typedef enum {
    kDirection_topBottom = 0,
    kDirection_leftRight,
    kDirection_rightLeft,
    kDirection_bottomTop,
    kDirection_none
}eDirection;;



@interface ViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController {
    CGSize _screenSize;
    eDirection _scrollingDirection;
    BOOL _isReloadTriggered;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _scrollingDirection = kDirection_none;
    _screenSize = [UIScreen mainScreen].bounds.size;
    
    _isReloadTriggered = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _scrollView.scrollEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_screenSize.width + 1, _screenSize.height + 1);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIScrollView Delegate

#define kOffsetTrigger_TopBottom -80.0f
#define kOffsetTrigger_BottomTop 80.0f
#define kOffsetTrigger_LeftRight -80.0f
#define kOffsetTrigger_RightLeft 80.0f


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    _scrollView.scrollEnabled = NO;
    if ([self validateScrollViewOffsetTrigger]) {
        _isReloadTriggered = YES;
    }
}

- (IBAction)testAction:(id)sender {
    NSLog(@"test: %@", NSStringFromCGSize(_scrollView.contentSize));
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_isReloadTriggered) {
        _scrollingDirection = kDirection_none;
        _scrollView.scrollEnabled = YES;
    }
    else {
        _scrollView.contentOffset = CGPointMake(0, 0);
        _scrollingDirection = kDirection_none;
        _scrollView.scrollEnabled = YES;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrollingDirection == kDirection_none && !CGPointEqualToPoint(scrollView.contentOffset, CGPointZero)) {
        _scrollingDirection = [self determineScrollingDirectionFromContentOffset:scrollView.contentOffset];
    }
    else if (_scrollingDirection != kDirection_none) {
        scrollView.contentOffset = [self calculateValidOffset];
    }
}




#pragma mark - Helper Methods

- (eDirection)determineScrollingDirectionFromContentOffset:(CGPoint)offset {
    if (offset.x > 0 && offset.y > 0) {
        return offset.x >= offset.y ? kDirection_rightLeft : kDirection_bottomTop;
    }
    if (offset.x < 0 && offset.y < 0) {
        return offset.x <= offset.y ? kDirection_leftRight : kDirection_topBottom;
    }
    else if (offset.x > 0 && offset.y == 0) {
        return kDirection_rightLeft;
    }
    else if (offset.x < 0 && offset.y == 0) {
        return kDirection_leftRight;
    }
    else if (offset.x == 0 && offset.y < 0) {
        return kDirection_topBottom;
    }
    else if (offset.x == 0 && offset.y > 0) {
        return kDirection_bottomTop;
    }
    return kDirection_none;
}



#define kOffsetLimit_TopBottom -100.0f
#define kOffsetLimit_BottomTop 100.0f
#define kOffsetLimit_LeftRight -100.0f
#define kOffsetLimit_RightLeft 100.0f


- (CGPoint)calculateValidOffset {
    CGPoint contentOffset = _scrollView.contentOffset;
    switch (_scrollingDirection) {
        case kDirection_topBottom:
        {
            if (contentOffset.y <= kOffsetLimit_TopBottom) {
                return CGPointMake(0, kOffsetLimit_TopBottom);
            }
            else {
                return CGPointMake(0, contentOffset.y < 0 ? contentOffset.y : 0);
            }
            break;
        }
            
        case kDirection_bottomTop:
        {
            if (contentOffset.y >= kOffsetLimit_BottomTop) {
                return CGPointMake(0, kOffsetLimit_BottomTop);
            }
            else {
                return CGPointMake(0, contentOffset.y > 0 ? contentOffset.y : 0);
            }
            break;
        }
        case kDirection_leftRight:
        {
            if (contentOffset.x <= kOffsetLimit_LeftRight) {
                return CGPointMake(kOffsetLimit_LeftRight, 0);
            }
            else {
                return CGPointMake(contentOffset.x < 0 ? contentOffset.x : 0, 0);
            }
            break;
        }
        case kDirection_rightLeft:
        {
            if (contentOffset.x >= kOffsetLimit_RightLeft) {
                return CGPointMake(kOffsetLimit_RightLeft, 0);
            }
            else {
                return CGPointMake(contentOffset.x > 0 ? contentOffset.x : 0, 0);
            }
            break;
        }
        default:
            return CGPointZero;
    }
}


- (BOOL)validateScrollViewOffsetTrigger {
    if (_scrollingDirection == kDirection_topBottom) {
        if (_scrollView.contentOffset.y <= kOffsetTrigger_TopBottom) {
            [UIView animateWithDuration:0.3f animations:^{
                [_scrollView setContentOffset:CGPointMake(0, kOffsetTrigger_TopBottom) animated:NO];
            }];
            return YES;
        }
    }
    else if (_scrollingDirection == kDirection_bottomTop) {
        if (_scrollView.contentOffset.y >= kOffsetTrigger_BottomTop) {
            [UIView animateWithDuration:0.3f animations:^{
                [_scrollView setContentOffset:CGPointMake(0, kOffsetTrigger_BottomTop) animated:NO];
            }];
            return YES;
        }
    }
    if (_scrollingDirection == kDirection_leftRight) {
        if (_scrollView.contentOffset.x <= kOffsetTrigger_LeftRight) {
            [UIView animateWithDuration:0.3f animations:^{
                [_scrollView setContentOffset:CGPointMake(kOffsetTrigger_LeftRight, 0) animated:NO];
            }];
            return YES;
        }
    }
    else if (_scrollingDirection == kDirection_rightLeft) {
        if (_scrollView.contentOffset.x >= kOffsetTrigger_RightLeft) {
            [UIView animateWithDuration:0.3f animations:^{
                [_scrollView setContentOffset:CGPointMake(kOffsetTrigger_RightLeft, 0) animated:NO];
            }];
            return YES;
        }
    }
    return NO;
}


@end
