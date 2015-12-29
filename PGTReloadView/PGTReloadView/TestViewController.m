//
//  TestViewController.m
//  PGTReloadView
//
//  Created by Reinhard on 26/12/15.
//  Copyright © 2015 PGIT. All rights reserved.
//

#import "TestViewController.h"
#import "PGTReloadView.h"

@interface TestViewController ()

@property (weak, nonatomic) IBOutlet PGTReloadView *reloadView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _reloadView.supportedReloadDirections = kReloadDirection_topBottom | kReloadDirection_leftRight | kReloadDirection_rightLeft | kReloadDirection_bottomTop;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
