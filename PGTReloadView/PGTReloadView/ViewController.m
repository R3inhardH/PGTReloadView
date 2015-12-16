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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _scrollingDirection = kDirection_none;
    _screenSize = [UIScreen mainScreen].bounds.size;
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


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    _scrollView.scrollEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _scrollView.contentOffset = CGPointMake(0, 0);
    _scrollView.contentSize = CGSizeMake(_screenSize.width + 1, _screenSize.height + 1);
    _scrollingDirection = kDirection_none;
    _scrollView.scrollEnabled = YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrollingDirection == kDirection_none && !CGPointEqualToPoint(scrollView.contentOffset, CGPointZero)) {
        _scrollingDirection = [self directionFromContentOffset:scrollView.contentOffset];
        if (_scrollingDirection == kDirection_leftRight || _scrollingDirection == kDirection_rightLeft) {
            _scrollView.contentSize = CGSizeMake(_screenSize.width + 1, _screenSize.height);
        }
        else {
            _scrollView.contentSize = CGSizeMake(_screenSize.width, _screenSize.height + 1);
        }
    }
    else {
        if ([self isScrollingOutOfBorderLimit:_scrollingDirection]) {
            _scrollView.contentOffset = CGPointMake(0, 0);
        }
    }
}


- (eDirection)directionFromContentOffset:(CGPoint)offset {
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


- (BOOL)isScrollingOutOfBorderLimit:(eDirection)activeScrollingDirection {
    eDirection currentScrollingDirection = [self directionFromContentOffset:_scrollView.contentOffset];
    if (activeScrollingDirection == currentScrollingDirection) {
        return NO;
    }
    
    if (activeScrollingDirection == kDirection_bottomTop && currentScrollingDirection == kDirection_topBottom) {
        return YES;
    }
    if (activeScrollingDirection == kDirection_topBottom && currentScrollingDirection == kDirection_bottomTop) {
        return YES;
    }
    if (activeScrollingDirection == kDirection_rightLeft && currentScrollingDirection == kDirection_leftRight) {
        return YES;
    }
    if (activeScrollingDirection == kDirection_leftRight && currentScrollingDirection == kDirection_rightLeft) {
        return YES;
    }
    
    return NO;
}

@end
