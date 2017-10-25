//
//  ZJNDatePicker.h
//  ZJNDatePicker
//
//  Created by 朱佳男 on 2017/10/24.
//  Copyright © 2017年 ShangYuKeJi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    DateStyleShowYearMonthDayHourMinute = 0,
    DateStyleShowYearMonthDay,
    DateStyleShowMonthDayHourMinute,
    DateStyleShowMonthDay,
    DateStyleShowHourMinute
}ZJNDateStyle;

typedef enum{
    DateTypeStartDate,
    DateTypeEndDate
} ZJNDateType;
@interface ZJNDatePicker : UIView
@property (nonatomic ,assign)ZJNDateStyle datePickerStyle;
@property (nonatomic ,assign)ZJNDateType  dateType;
@property (nonatomic ,strong)UIColor      *themeColor;

@property (nonatomic ,strong)NSDate       *maxLimitDate;
@property (nonatomic ,strong)NSDate       *minLimitDate;

-(instancetype)initWithCompleteBlock:(void(^)(NSDate *,NSDate *))completeBlock;
/**
 *   设置打开选择器时的默认时间，
 *   minLimitDate < currentDate < maxLimitDate  显示 currentDate;
 *   currentDate < minLimitDate ||  currentDate > maxLimitDate   显示minLimitDate;
 */
-(instancetype)initWithCurrentDate:(NSDate *)currentDate completeBlock:(void(^)(NSDate *,NSDate *))completeBlock;

-(void)show;
@end
