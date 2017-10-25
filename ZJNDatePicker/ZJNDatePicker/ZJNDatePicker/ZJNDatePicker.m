//
//  ZJNDatePicker.m
//  ZJNDatePicker
//
//  Created by 朱佳男 on 2017/10/24.
//  Copyright © 2017年 ShangYuKeJi. All rights reserved.
//

#import "ZJNDatePicker.h"
#import "NSDate+Extension.h"
#import "UIView+Extension.h"

#define KSCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define KSCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define KPICKERSIZE self.datePicker.frame.size
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1)

#define MAXYEAR 2050
#define MINYEAR 1970

typedef void (^doneBlock)(NSDate *,NSDate *);

@interface ZJNDatePicker()<UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate>{
    //日期存储数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    NSMutableArray *_hourArray;
    NSMutableArray *_minuteArray;
    NSString       *_dateFormatter;
    //记录位置
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger minuteIndex;
    
    NSInteger preRow;
    
    NSDate *_statrDate;
    NSDate *_endDate;
}
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UILabel *bgYearLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;

@property (nonatomic ,strong)UIPickerView *datePicker;
@property (nonatomic ,strong)NSDate       *scrollToDate;//滚到指定日期
@property (nonatomic ,strong)doneBlock     doneBlock;
@property (nonatomic ,strong)NSDate       *currentDate;//默认显示时间


@end
@implementation ZJNDatePicker
-(instancetype)initWithCompleteBlock:(void (^)(NSDate *, NSDate *))completeBlock{
    return [self initWithCurrentDate:nil completeBlock:completeBlock];
}
-(instancetype)initWithCurrentDate:(NSDate *)currentDate completeBlock:(void (^)(NSDate *, NSDate *))completeBlock{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:self options:nil]lastObject];
        self.currentDate = currentDate;
        _dateFormatter   = @"yyyy-MM-dd HH:mm";
        [self setupUI];
        [self defaultConfig];
        if (completeBlock) {
            self.doneBlock = ^(NSDate *startDate, NSDate *endDate) {
                completeBlock(startDate,endDate);
            };
        }
    }
    return self;
}
-(void)setupUI{
    self.segmentView.selectedSegmentIndex = 0;
    [self.segmentView addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    self.bottomView.layer.cornerRadius = 10;
    self.bottomView.layer.masksToBounds = YES;
    self.themeColor = RGB(247, 133, 51);
    self.frame = CGRectMake(0, 0, KSCREENWIDTH, KSCREENHEIGHT);
    
    //点击背景是否隐藏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    self.bottomViewBottomConstraint.constant = -self.height;
    self.backgroundColor = RGBA(0, 0, 0, 0);
    [self layoutIfNeeded];
    
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    [self.bgYearLabel addSubview:self.datePicker];
}

-(void)defaultConfig{
    if (!_scrollToDate) {
        _scrollToDate = self.currentDate?self.currentDate:[NSDate date];
    }
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year-MINYEAR)*12 + self.scrollToDate.month-1;
    
    //设置年月日时分数据
    _yearArray  = [self setArray:_yearArray];
    _monthArray = [self setArray:_monthArray];
    _dayArray   = [self setArray:_dayArray];
    _hourArray  = [self setArray:_hourArray];
    _minuteArray= [self setArray:_minuteArray];
    
    for (int i = 0; i <60; i ++) {
        NSString *num = [NSString stringWithFormat:@"%02d",i];
        if (0<i && i<=12) {
            [_monthArray addObject:num];
        }
        if (i<24) {
            [_hourArray addObject:num];
        }
        [_minuteArray addObject:num];
    }
    for (NSInteger i = MINYEAR; i <MAXYEAR; i ++) {
        NSString *num = [NSString stringWithFormat:@"%ld",(long)i];
        [_yearArray addObject:num];
    }
    //最大限制
    if (!self.maxLimitDate) {
        self.maxLimitDate = [NSDate date:@"2049-12-31 23:59" WithFormat:@"yyyy-MM-dd HH:mm"];
    }
    //最小限制
    if (!self.minLimitDate) {
        self.minLimitDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
}

- (NSMutableArray *)setArray:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

-(void)addLabelWithName:(NSArray *)nameArray{
    for (id subView in self.bgYearLabel.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [subView removeFromSuperview];
        }
    }
    for (int i = 0; i <nameArray.count; i ++) {
        CGFloat labelX = KPICKERSIZE.width/(nameArray.count*2)+18+KPICKERSIZE.width/nameArray.count*i;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(labelX, self.bgYearLabel.frame.size.height/2-15, 15, 15)];
        label.text = nameArray[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = self.themeColor;
        label.backgroundColor = [UIColor clearColor];
        [self.bgYearLabel addSubview:label];
    }
}
#pragma mark--segmentAction
-(void)segmentAction:(UISegmentedControl *)segment {
    self.dateType = (int)segment.selectedSegmentIndex;
}
#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch (self.datePickerStyle) {
        case DateStyleShowYearMonthDayHourMinute:
            [self addLabelWithName:@[@"年",@"月",@"日",@"时",@"分"]];
            return 5;
            break;
        case DateStyleShowYearMonthDay:
            [self addLabelWithName:@[@"年",@"月",@"日"]];
            return 3;
            break;
        case DateStyleShowMonthDayHourMinute:
            [self addLabelWithName:@[@"月",@"日",@"时",@"分"]];
            return 4;
            break;
        case DateStyleShowMonthDay:
            [self addLabelWithName:@[@"月",@"日"]];
            return 2;
            break;
        case DateStyleShowHourMinute:
            [self addLabelWithName:@[@"时",@"分"]];
            return 2;
            break;
        default:
            return 0;
            break;
    }
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSArray *numberArr = [self getNumberOfRowsInComponent];
    return [numberArr[component] integerValue];
}
-(NSArray *)getNumberOfRowsInComponent{
    NSInteger yearNum   = _yearArray.count;
    NSInteger monthNum  = _monthArray.count;
    NSInteger dayNum    = [self dayFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
    NSInteger hourNum   = _hourArray.count;
    NSInteger minuteNum = _minuteArray.count;
    
    NSInteger timeInterval = MAXYEAR-MINYEAR;
    
    switch (self.datePickerStyle) {
        case DateStyleShowYearMonthDayHourMinute:
            return @[@(yearNum),@(monthNum),@(dayNum),@(hourNum),@(minuteNum)];
            break;
        case DateStyleShowMonthDayHourMinute:
            return @[@(monthNum*timeInterval),@(dayNum),@(hourNum),@(minuteNum)];
            break;
        case DateStyleShowYearMonthDay:
            return @[@(yearNum),@(monthNum),@(dayNum)];
            break;
        case DateStyleShowHourMinute:
            return @[@(hourNum),@(minuteNum)];
            break;
        case DateStyleShowMonthDay:
            return @[@(monthNum),@(dayNum)];
            break;
        default:
            return @[];
            break;
    }
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc]init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:17]];
    }
    NSString *title;
    switch (self.datePickerStyle) {
        case DateStyleShowYearMonthDayHourMinute:
            if (component == 0) {
                title = _yearArray[row];
            }else if (component == 1){
                title = _monthArray[row];
            }else if (component == 2){
                title = _dayArray[row];
            }else if (component == 3){
                title = _hourArray[row];
            }else if (component == 4){
                title = _minuteArray[row];
            }
            break;
        case DateStyleShowMonthDayHourMinute:
            if (component == 0) {
                title = _monthArray[row%12];
            }else if (component == 1){
                title = _dayArray[row];
            }else if (component == 2){
                title = _hourArray[row];
            }else if (component == 3){
                title = _minuteArray[row];
            }
            break;
        case DateStyleShowYearMonthDay:
            if (component == 0) {
                title = _yearArray[row];
            }else if (component == 1){
                title = _monthArray[row];
            }else if (component == 2){
                title = _dayArray[row];
            }
            break;
        case DateStyleShowHourMinute:
            if (component == 0) {
                title = _hourArray[row];
            }else if (component == 1){
                title = _minuteArray[row];
            }
            break;
        case DateStyleShowMonthDay:
            if (component == 0) {
                title = _monthArray[row%12];
            }else if (component == 1){
                title = _dayArray[row];
            }
        default:
            title = @"";
            break;
    }
    customLabel.text = title;
    customLabel.textColor = [UIColor blackColor];
    return customLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (self.datePickerStyle) {
        case DateStyleShowYearMonthDayHourMinute:
            {
                if (component == 0) {
                    yearIndex = row;
                    self.bgYearLabel.text = _yearArray[row];
                }else if (component == 1){
                    monthIndex = row;
                }else if (component == 2){
                    dayIndex = row;
                }else if (component == 3){
                    hourIndex = row;
                }else if (component == 4){
                    minuteIndex = row;
                }
                if (component == 0||component == 1) {
                    [self dayFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                    if (_dayArray.count-1<dayIndex) {
                        dayIndex = _dayArray.count-1;
                    }
                }
            }
            break;
         case DateStyleShowMonthDayHourMinute:
            {
                if (component == 0) {
                    [self yearChange:row];
                    [self dayFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                    if (_dayArray.count-1<dayIndex) {
                        dayIndex = _dayArray.count-1;
                    }
                }else if (component == 1){
                    dayIndex = row;
                }else if (component == 2){
                    hourIndex = row;
                }else if (component == 3){
                    minuteIndex = row;
                }
            }
            break;
          case DateStyleShowYearMonthDay:
             {
                 if (component == 0) {
                     yearIndex = row;
                     self.bgYearLabel.text = _yearArray[row];
                 }else if (component == 1){
                     monthIndex = row;
                 }else if (component == 2){
                     dayIndex = row;
                 }
                 if (component == 0||component == 1) {
                     [self dayFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                     if (_dayArray.count-1<dayIndex) {
                         dayIndex = _dayArray.count-1;
                     }
                 }
             }
            break;
          case DateStyleShowMonthDay:
            {
                if (component == 0) {
                    [self yearChange:row];
                    [self dayFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                    if (_dayArray.count-1<dayIndex) {
                        dayIndex = _dayArray.count-1;
                    }
                }else if (component == 1){
                    dayIndex = row;
                }
            }
            break;
          case DateStyleShowHourMinute:
            {
                if (component == 0) {
                    hourIndex = row;
                }
                if (component == 1) {
                    minuteIndex = row;
                }
            }
            break;
        default:
            break;
    }
    [pickerView reloadAllComponents];
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex],_minuteArray[minuteIndex]];
    
    self.scrollToDate = [[NSDate date:dateStr WithFormat:@"yyyy-MM-dd HH:mm"] dateWithFormatter:_dateFormatter];

    if ([self.scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        self.scrollToDate = self.minLimitDate;
        
    }else if ([self.scrollToDate compare:self.maxLimitDate] == NSOrderedDescending){
        self.scrollToDate = self.maxLimitDate;
    }
    [self getNowDate:self.scrollToDate animated:YES];
    switch (self.dateType) {
        case DateTypeStartDate:
            _statrDate = self.scrollToDate;
            break;
            
        default:
            _endDate = self.scrollToDate;
            break;
    }
}

-(void)yearChange:(NSInteger)row{
    monthIndex = row%12;
    //年份状态变化
    if (row-preRow <12 && row-preRow>0 && [_monthArray[monthIndex] integerValue] < [_monthArray[preRow%12] integerValue]) {
        yearIndex ++;
    } else if(preRow-row <12 && preRow-row > 0 && [_monthArray[monthIndex] integerValue] > [_monthArray[preRow%12] integerValue]) {
        yearIndex --;
    }else {
        NSInteger interval = (row-preRow)/12;
        yearIndex += interval;
    }
    
    self.bgYearLabel.text = _yearArray[yearIndex];
    
    preRow = row;
}

//滚动到指定的时间位置
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date) {
        date = [NSDate date];
    }
    
    [self dayFromYear:date.year andMonth:date.month];
    yearIndex = date.year-MINYEAR;
    monthIndex = date.month-1;
    dayIndex = date.day-1;
    hourIndex = date.hour;
    minuteIndex = date.minute;
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year-MINYEAR)*12+self.scrollToDate.month-1;
    
    NSArray *indexArray;
    
    if (self.datePickerStyle == DateStyleShowYearMonthDayHourMinute)
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
    if (self.datePickerStyle == DateStyleShowYearMonthDay)
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex)];
    if (self.datePickerStyle == DateStyleShowMonthDayHourMinute)
        indexArray = @[@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
    if (self.datePickerStyle == DateStyleShowMonthDay)
        indexArray = @[@(monthIndex),@(dayIndex)];
    if (self.datePickerStyle == DateStyleShowHourMinute)
        indexArray = @[@(hourIndex),@(minuteIndex)];
    
    self.bgYearLabel.text = _yearArray[yearIndex];
    
    [self.datePicker reloadAllComponents];
    
    for (int i=0; i<indexArray.count; i++) {
        if ((self.datePickerStyle == DateStyleShowMonthDayHourMinute || self.datePickerStyle == DateStyleShowMonthDay)&& i==0) {
            NSInteger mIndex = [indexArray[i] integerValue]+(12*(self.scrollToDate.year - MINYEAR));
            [self.datePicker selectRow:mIndex inComponent:i animated:animated];
        } else {
            [self.datePicker selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
        }
        
    }
}
#pragma mark--通过年月求每月数据
-(NSInteger)dayFromYear:(NSInteger)year andMonth:(NSInteger)month{
    NSInteger year_num = year;
    NSInteger month_num = month;
    BOOL isRunNian = year_num%4==0?(year_num%100==0?(year_num%400==0?YES:NO):YES):NO;
    switch (month_num) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:
            {
                [self setDayArray:31];
                return 31;
            }
            break;
        case 4:case 6:case 9:case 11:
           {
               [self setDayArray:30];
               return 30;
           }
        case 2:
           {
               if (isRunNian) {
                   [self setDayArray:29];
                   return 29;
               }else{
                   [self setDayArray:28];
                   return 28;
               }
           }
        default:
            return 0;
            break;
    }
}
-(void)setDayArray:(NSInteger)num{
    [_dayArray removeAllObjects];
    for (int i = 1; i <=num; i ++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%ld",(long)i]];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if( [touch.view isDescendantOfView:self.bottomView]) {
        return NO;
    }
    return YES;
}
#pragma mark - Action
-(void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:.3 animations:^{
        self.bottomViewBottomConstraint.constant = 10;
        self.backgroundColor = RGBA(0, 0, 0, 0.4);
        [self layoutIfNeeded];
    }];
}
-(void)dismiss {
    [UIView animateWithDuration:.3 animations:^{
        self.bottomViewBottomConstraint.constant = -self.height;
        self.backgroundColor = RGBA(0, 0, 0, 0);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    }];
}

#pragma mark - getter / setter
-(UIPickerView *)datePicker {
    if (!_datePicker) {
        [self.bgYearLabel layoutIfNeeded];
        _datePicker = [[UIPickerView alloc] initWithFrame:self.bgYearLabel.bounds];
        _datePicker.showsSelectionIndicator = YES;
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
    }
    return _datePicker;
}

-(void)setMinLimitDate:(NSDate *)minLimitDate {
    _minLimitDate = minLimitDate;
    if ([_scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        _scrollToDate = self.minLimitDate;
    }
    [self getNowDate:self.scrollToDate animated:NO];
}

-(void)setMaxLimitDate:(NSDate *)maxLimitDate {
    _maxLimitDate = maxLimitDate;
    if ([_scrollToDate compare:self.minLimitDate] == NSOrderedDescending) {
        _scrollToDate = self.minLimitDate;
    }
    [self getNowDate:self.scrollToDate animated:NO];
}

-(void)setThemeColor:(UIColor *)themeColor {
    _themeColor = themeColor;
    self.segmentView.tintColor = themeColor;
    self.bottomButton.backgroundColor = themeColor;
}

-(void)setDateType:(ZJNDateType)dateType {
    _dateType = dateType;
    switch (dateType) {
        case DateTypeStartDate:
            self.segmentView.selectedSegmentIndex = 0;
            break;
            
        default:
            self.segmentView.selectedSegmentIndex = 1;
            break;
    }
}
- (IBAction)doneAction:(UIButton *)sender {
    switch (self.dateType) {
        case DateTypeStartDate:
            _statrDate = [self.scrollToDate dateWithFormatter:_dateFormatter];
            break;
            
        default:
            _endDate = [self.scrollToDate dateWithFormatter:_dateFormatter];
            break;
    }
    
    self.doneBlock(_statrDate,_endDate);
    [self dismiss];
}
-(void)setDatePickerStyle:(ZJNDateStyle)datePickerStyle {
    _datePickerStyle = datePickerStyle;
    switch (datePickerStyle) {
            break;
        case DateStyleShowYearMonthDay:
        case DateStyleShowMonthDay:
            _dateFormatter = @"yyyy-MM-dd";
            break;
            
        default:
            break;
    }
    [self.datePicker reloadAllComponents];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
