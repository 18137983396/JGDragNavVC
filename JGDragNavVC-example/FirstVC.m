//
//  FirstVC.m
//  JGDragNavVC-example
//
//  Created by 极光 on 2017/8/21.
//  Copyright © 2017年 极光. All rights reserved.
//

#import "FirstVC.h"
#import "SecondVC.h"
#import "JGDragNavVC.h"

@interface FirstVC ()

@end

@implementation FirstVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
}

#pragma mark - UI
- (void)setUpUI {
    self.view.backgroundColor = [UIColor grayColor];
    self.title = @"FirstVC";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width - 100)/2, (self.view.frame.size.height - 50)/2, 100, 50);
    [button setTitle:@"push" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(buttonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark - Action
- (void)buttonClickAction {
    SecondVC *pushVC = [[SecondVC alloc] init];
    [self.navigationController pushViewController:pushVC animated:YES];
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
