//
//  TestViewController.m
//  PGTReloadView
//
//  Created by Reinhard on 26/12/15.
//  Copyright © 2015 PGIT. All rights reserved.
//

#import "TestViewController.h"
#import "PGTReloadView.h"

@interface TestViewController () <PGTReloadViewDelegate>

@property (weak, nonatomic) IBOutlet PGTReloadView *reloadView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _reloadView.supportedReloadDirections = kReloadDirection_topBottom | kReloadDirection_leftRight | kReloadDirection_rightLeft | kReloadDirection_bottomTop;
    _reloadView.supportedReloadDirections = kReloadDirection_topBottom | kReloadDirection_leftRight | kReloadDirection_bottomTop | kReloadDirection_rightLeft;
    _reloadView.reloadViewDelegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)reloadView:(PGTReloadView *)reloadView didTriggerForDirection:(eReloadDirection)reloadDirection {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_reloadView resetOffset];
    });
}



- (IBAction)didPressResetOffsetButton:(id)sender {
    [_reloadView resetOffset];
}


- (IBAction)testAction:(id)sender {
    [_reloadView test];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
