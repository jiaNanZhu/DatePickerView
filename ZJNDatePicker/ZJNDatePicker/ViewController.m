//
//  ViewController.m
//  ZJNDatePicker
//
//  Created by 朱佳男 on 2017/10/24.
//  Copyright © 2017年 ShangYuKeJi. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extension.h"
#import "ZJNDatePicker/ZJNDatePicker.h"
#import "NSDate+Extension.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dateButton.frame = CGRectMake(0, 64, self.view.bounds.size.width, 44);
    dateButton.backgroundColor = [UIColor blackColor];
    [dateButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dateButton];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)buttonAction:(UIButton *)button{
    NSDate *currentDate = [NSDate date];
    NSString *currentDateString = [currentDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
    ZJNDatePicker *datePicker = [[ZJNDatePicker alloc]initWithCurrentDate:[NSDate date:currentDateString WithFormat:@"yyyy-MM-dd HH:mm"] completeBlock:^(NSDate *startDate, NSDate *endDate) {
        NSLog(@"%@--%@",startDate,endDate);
    }];
    
    datePicker.datePickerStyle = DateStyleShowMonthDayHourMinute;
    datePicker.dateType = DateTypeStartDate;
    
    datePicker.minLimitDate = [NSDate date:currentDateString WithFormat:@"yyyy-MM-dd HH:mm"];
    datePicker.maxLimitDate = [NSDate date:@"2050-01-01 00:00" WithFormat:@"yyyy-MM-dd HH:mm"];
    [datePicker show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
