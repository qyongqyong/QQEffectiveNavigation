//
//  FirstViewController.m
//  QQEffectiveNavigation
//
//  Created by qiongqiong on 2020/6/5.
//  Copyright © 2020 qiongqiong. All rights reserved.
//

#import "FirstViewController.h"
#import <QQEffectiveNavigation/UINavigationController+QQEffectiveNavigation.h>
#import "SecondViewController.h"


@interface FirstViewController ()

/** <#注释#> */
@property (nonatomic, strong) UIButton *button;

@end

@implementation FirstViewController

- (void)dealloc {
    NSLog(@"[%@ dealloc]", [self class]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        
//        self.qq_navigationBarTranslucent = false;
//        self.qq_prefersNavigationBarHidden = true;
//        self.qq_effectiveNavigatonDisabled = true;
//        self.qq_navigationBarBackgroundAlpha = 0;
//        self.qq_tintColor = UIColor.redColor;
//        self.qq_barTintColor = UIColor.cyanColor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"一";
    self.view.backgroundColor = UIColor.redColor;
    [self.view addSubview:self.button];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一返" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.qq_navigationBarBackgroundAlpha = 0;
    self.qq_tintColor = UIColor.redColor;
    self.qq_barTintColor = UIColor.cyanColor;
}

- (void)__buttonClicked {
    [self.navigationController pushViewController:[[SecondViewController alloc] init] animated:true];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.navigationController pushViewController:[[SecondViewController alloc] init] animated:true];
}

- (UIButton *)button {
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        _button.frame = CGRectMake(100, 100, 100, 100);
        [_button addTarget:self action:@selector(__buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
@end
