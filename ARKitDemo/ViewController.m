//
//  ViewController.m
//  ARKitDemo
//
//  Created by iwenan on 2017/8/21.
//  Copyright © 2017年 iwenan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 100);
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(arkitTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)arkitTest {
    ARSCNViewController *vc = [[ARSCNViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
