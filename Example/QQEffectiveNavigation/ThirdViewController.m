//
//  ThirdViewController.m
//  QQEffectiveNavigation
//
//  Created by qiongqiong on 2020/6/10.
//  Copyright © 2020 qiongqiong. All rights reserved.
//

#import "ThirdViewController.h"
#import <QQEffectiveNavigation/UINavigationController+QQEffectiveNavigation.h>

@interface ThirdViewController ()
/** <#注释#> */
@property (nonatomic, strong) UIButton *button;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"三";
    self.view.backgroundColor = UIColor.blueColor;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"三返" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.view addSubview:self.button];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一返" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.qq_tintColor = UIColor.yellowColor;
    self.qq_barTintColor = UIColor.magentaColor;
}


- (void)__buttonClicked {
    [self.navigationController popViewControllerAnimated:true];
}

- (UIButton *)button {
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        _button.frame = CGRectMake(100, 100, 100, 100);
        [_button addTarget:self action:@selector(__buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
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
