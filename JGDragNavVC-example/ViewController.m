//
//  ViewController.m
//  JGDragNavVC-example
//
//  Created by 极光 on 2017/8/21.
//  Copyright © 2017年 极光. All rights reserved.
//

#import "ViewController.h"
#import "JGDragNavVC.h"
#import "PushController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width - 100)/2, (self.view.frame.size.height - 50)/2, 100, 50);
    [button setTitle:@"click" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(buttonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClickAction {
    PushController *pushVC = [[PushController alloc] init];
    JGDragNavVC *nav = [[JGDragNavVC alloc] initWithRootViewController:pushVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
