//
//  ViewController.m
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

#define PNTwitterColor  [UIColor colorWithRed:0.0 / 255.0 green:171.0 / 255.0 blue:243.0 / 255.0 alpha:1.0]

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"CHPerformance Analyzer";
    // Do any additional setup after loading the view, typically from a nib.
    _button = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 200, 40)];
    [_button setTitle:@"WebView(Clicked me)" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _button.backgroundColor = PNTwitterColor;
    [_button addTarget:self
                action:@selector(onButton:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onButton:(id)sender
{
    WebViewController *vc = [WebViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
