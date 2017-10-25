//
//  NSDate+Extension.h
//  SmartLock
//
//  Created by 江欣华 on 2016/10/25.
//  Copyright © 2016年 工程锁. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface NSDate (Extension)

+ (NSCalendar *) currentCalendar; // avoid bottlenecks

// Relative dates from the current date
+ (NSDate *) dateTomorrow;//明天的日期
+ (NSDate *) dateYesterday;//昨天的日期
+ (NSDate *) dateWithDaysFromNow: (NSInteger) days;//几天后的日期
+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days;//几天前的日期
+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours;//几小时后的日期
+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours;//几小时前的日期
+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes;//几分钟后的日期
+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes;//几分钟前的日期
+ (NSDate *) date:(NSString *)datestr WithFormat:(NSString *)format;//

// Short string utilities
- (NSString *) stringWithDateStyle: (NSDateFormatterStyle) dateStyle timeStyle: (NSDateFormatterStyle) timeStyle;
- (NSString *) stringWithFormat: (NSString *) format;
@property (nonatomic, readonly) NSString *shortString;
@property (nonatomic, readonly) NSString *shortDateString;
@property (nonatomic, readonly) NSString *shortTimeString;
@property (nonatomic, readonly) NSString *mediumString;
@property (nonatomic, readonly) NSString *mediumDateString;
@property (nonatomic, readonly) NSString *mediumTimeString;
@property (nonatomic, readonly) NSString *longString;
@property (nonatomic, readonly) NSString *longDateString;
@property (nonatomic, readonly) NSString *longTimeString;

// Comparing dates
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;//忽略时间 比较日期

- (BOOL) isToday;//今天
- (BOOL) isTomorrow;//明天
- (BOOL) isYesterday;//昨天

- (BOOL) isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) isThisWeek;
- (BOOL) isNextWeek;
- (BOOL) isLastWeek;

- (BOOL) isSameMonthAsDate: (NSDate *) aDate;
- (BOOL) isThisMonth;
- (BOOL) isNextMonth;
- (BOOL) isLastMonth;

- (BOOL) isSameYearAsDate: (NSDate *) aDate;
- (BOOL) isThisYear;
- (BOOL) isNextYear;
- (BOOL) isLastYear;

- (BOOL) isEarlierThanDate: (NSDate *) aDate;//此日期之前
- (BOOL) isLaterThanDate: (NSDate *) aDate;//此日期之后

- (BOOL) isInFuture;//将来的时间
- (BOOL) isInPast;//已经过去

// Date roles
- (BOOL) isTypicallyWorkday;//是工作日
- (BOOL) isTypicallyWeekend;//是周末

// Adjusting dates
- (NSDate *) dateByAddingYears: (NSInteger) dYears;//几年后的今天
- (NSDate *) dateBySubtractingYears: (NSInteger) dYears;//几年前的今天
- (NSDate *) dateByAddingMonths: (NSInteger) dMonths;//几个月后的今天
- (NSDate *) dateBySubtractingMonths: (NSInteger) dMonths;//几个月前的今天
- (NSDate *) dateByAddingDays: (NSInteger) dDays;//n天后的日期
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;//n天前的日期
- (NSDate *) dateByAddingHours: (NSInteger) dHours;//n小时后的日期
- (NSDate *) dateBySubtractingHours: (NSInteger) dHours;//n小时前的日期
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;//n分钟后的日期
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;//n分钟前的日期

// Date extremes
- (NSDate *) dateAtStartOfDay;//一天的起始时间
- (NSDate *) dateAtEndOfDay;//一天的结束时间

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

- (NSDate *)dateWithYMD;
- (NSDate *)dateWithFormatter:(NSString *)formatter;

@end
