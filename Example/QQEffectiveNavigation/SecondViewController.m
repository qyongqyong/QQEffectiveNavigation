//
//  SecondViewController.m
//  QQEffectiveNavigation
//
//  Created by qiongqiong on 2020/6/5.
//  Copyright © 2020 qiongqiong. All rights reserved.
//

#import "SecondViewController.h"
#import "ThirdViewController.h"
#import <QQEffectiveNavigation/UINavigationController+QQEffectiveNavigation.h>

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)dealloc {
    NSLog(@"[%@ dealloc]", [self class]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    NSLog(@"qq_navigationBar.subviews - %@", self.qq_navigationBar.subviews);
//    self.qq_navigationBar.subviews.firstObject.frame = CGRectMake(0, -44, 375, 88);
//    NSLog(@"qq_navigationBar.subviews - %@", self.qq_navigationBar.subviews);
//}
//
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"二";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:^UIButton *(){
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [button setTitle:@"二返" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.yellowColor forState:UIControlStateNormal];
        return button;
    }()];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"二右" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.view.backgroundColor = UIColor.greenColor;
    self.navigationItem.leftItemsSupplementBackButton = true;
    self.qq_barTintColor = UIColor.greenColor;
    self.qq_tintColor = UIColor.blueColor;
    self.qq_navigationBarBackgroundAlpha = 0;
    self.qq_navigationBarTranslucent = false;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.navigationController pushViewController:[[ThirdViewController alloc] init] animated:true];
}

@end
