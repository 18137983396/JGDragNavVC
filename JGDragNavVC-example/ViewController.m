//
//  ViewController.m
//  JGDragNavVC-example
//
//  Created by 极光 on 2017/8/21.
//  Copyright © 2017年 极光. All rights reserved.
//

#import "ViewController.h"
#import "JGDragNavVC.h"
#import "FirstVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

#pragma mark - UI
- (void)setUpUI {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width - 100)/2, (self.view.frame.size.height - 50)/2, 100, 50);
    [button setTitle:@"click" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(buttonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark - Action
- (void)buttonClickAction {
    FirstVC *pushVC = [[FirstVC alloc] init];
    JGDragNavVC *nav = [[JGDragNavVC alloc] initWithRootViewController:pushVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
