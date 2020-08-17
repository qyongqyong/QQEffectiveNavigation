//
//  QQViewController.m
//  QQEffectiveNavigation
//
//  Created by qiongqiong on 08/17/2020.
//  Copyright (c) 2020 qiongqiong. All rights reserved.
//

#import "QQViewController.h"
#import "FirstViewController.h"
#import <QQEffectiveNavigation/UINavigationController+QQEffectiveNavigation.h>

@interface QQViewController ()

@end

@implementation QQViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"qq_navigationBar.subviews - %@", self.qq_navigationBar.subviews);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSLog(@"qq_navigationBar.subviews - %@", self.qq_navigationBar.subviews);
//    self.qq_navigationBar.subviews.firstObject.frame = CGRectMake(0, -44, 375, 88);
//    NSLog(@"qq_navigationBar.subviews - %@", self.qq_navigationBar.subviews);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"首页";
    self.view.backgroundColor = UIColor.greenColor;
//    self.qq_systemNavigationBarHidden = true;
    self.qq_barTintColor = UIColor.redColor;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.navigationController pushViewController:[[FirstViewController alloc] init] animated:true];
}

@end
