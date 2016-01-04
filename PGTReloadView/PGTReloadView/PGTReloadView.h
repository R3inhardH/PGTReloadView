//
//  PGTReloadView.h
//  PGTReloadView
//
//  Created by Reinhard on 26/12/15.
//  Copyright © 2015 PGIT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PGTReloadView;


typedef enum {
    kReloadDirection_none = 0,
    kReloadDirection_topBottom = 1 << 0,
    kReloadDirection_leftRight = 1 << 1,
    kReloadDirection_rightLeft = 1 << 2,
    kReloadDirection_bottomTop = 1 << 3
}eReloadDirection;





@protocol PGTReloadViewDelegate <NSObject>

- (void)reloadView:(PGTReloadView *)reloadView didScrollInDirection:(eReloadDirection)reloadDirection;
- (void)reloadView:(PGTReloadView *)reloadView didTriggerForDirection:(eReloadDirection)reloadDirection;
- (void)reloadViewDidResetOffset:(PGTReloadView *)reloadView;

@end



@protocol PGTReloadViewDatasource <NSObject>

- (BOOL)shouldShowCustomReloadIconForDirection:(eReloadDirection)reloadDirection;
- (UIView *)reloadIconForDirection:(eReloadDirection)reloadDirection;

@end




@interface PGTReloadView : UIScrollView

@property (weak, nonatomic) id <PGTReloadViewDelegate> reloadDelegate;
@property (weak, nonatomic) id <PGTReloadViewDatasource> reloadDatasource;

@property (assign, nonatomic) eReloadDirection supportedReloadDirections;


@property (assign, nonatomic) CGFloat minOffsetTopBottom;
@property (assign, nonatomic) CGFloat minOffsetBottomTop;
@property (assign, nonatomic) CGFloat minOffsetLeftRight;
@property (assign, nonatomic) CGFloat minOffsetRightLeft;
@property (assign, nonatomic) CGFloat maxOffsetTopBottom;
@property (assign, nonatomic) CGFloat maxOffsetBottomTop;
@property (assign, nonatomic) CGFloat maxOffsetLeftRight;
@property (assign, nonatomic) CGFloat maxOffsetRightLeft;



- (void)resetOffset;
- (void)test;

@end
