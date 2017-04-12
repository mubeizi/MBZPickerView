//
//  MBZPickerView.m
//  MBZPickerView
//
//  Created by viktor on 17/4/10.
//
//

#import "MBZPickerView.h"

#define kSCREEN_W           [UIScreen mainScreen].bounds.size.width
#define kSCREEN_H           [UIScreen mainScreen].bounds.size.height
#define kMainWindow         [UIApplication sharedApplication].keyWindow


@interface MBZPickerView()
@property (nonatomic) UIWindow *rootWindow;
@property (nonatomic, strong) NSDictionary *dataDic;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *widthArr;         // 设置component的宽度
@property (nonatomic, assign) MBZPickerViewType pickerViewType;


@end

//定义弹出高度
static const CGFloat kPickerViewHeight = 250;
static const CGFloat kTopViewHeight    = 40;

@implementation MBZPickerView
{
    NSMutableArray   *_timeMutArr;
    
    UIView        *_topView;
    UIView        *_bgView;
    UIPickerView  *_pickerView;
    NSString      *_titleStr;
}

/** 带时间的默认初始化方式 */
-(instancetype)initWithTitle:(NSString *)titleStr withPickerViewType:(NSInteger)type
{
    if (self = [super init])
    {
        self.pickerViewType  = type;
        [self createViewWithTitle:titleStr];
        
    }
    return self;
}

/** 默认方式的初始化方式(每列数据不需要对应变动) */
-(instancetype)initWithTitle:(NSString *)titleStr withPickerViewType:(NSInteger)type andData:(NSArray *)dataArr
{
    if (self = [super init])
    {
        self.pickerViewType  = type;
        self.dataArr = [NSMutableArray array];
        _timeMutArr  = [NSMutableArray array];
        for (id object in dataArr) {
            if ([object isKindOfClass:[NSArray class]]) {
                [self.dataArr addObject:object];
                NSArray *array = object;
                [_timeMutArr addObject:array[0]];
            }else {
                [self.dataArr addObject:dataArr];
                [_timeMutArr addObject:self.dataArr[0][0]];
                break;
            }
        }
        NSLog(@"self.dataArr = %@",self.dataArr);
        [self createViewWithTitle:titleStr];
    }
    return self;
}


/** 联动类型的初始化方式(类似于区域,三层结构) */
-(instancetype)initWithTitle:(NSString *)titleStr withData:(NSDictionary *)dataDic
{
    if (self = [super init])
    {
        self.pickerViewType = MBZPickerViewType_LINKAGE;
        self.dataDic = [NSDictionary dictionary];
        self.dataDic = dataDic;
        
        [self createViewWithTitle:titleStr];
        
    }
    return self;
}






// 创建视图各个界面
- (void)createViewWithTitle:(NSString *)titleStr
{
    
    self.userInteractionEnabled = YES;
    self.frame = CGRectMake(0, kSCREEN_H, kSCREEN_W, kPickerViewHeight);
    self.backgroundColor = [UIColor whiteColor];
    
    // 默认初始值
    self.font = self.font ? self.font : 24.0;
    self.span = self.span ? self.span : 1;
    self.rowHeight = self.rowHeight ? self.rowHeight : 44;
    
    // 头部按钮视图
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_W, kTopViewHeight)];
    _topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
    [self addSubview:_topView];
    
    // 防止点击事件触发
    UITapGestureRecognizer *topTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [_topView addGestureRecognizer:topTap];
    
    // 创建pickerView的title
    CGFloat but_W = 60;             // 按钮的宽度
    UILabel *titleLB = [[UILabel alloc]initWithFrame:CGRectMake(but_W, 0, kSCREEN_W - but_W *2, kTopViewHeight)];
    titleLB.text = titleStr;
    titleLB.font = [UIFont systemFontOfSize:17];
    titleLB.textColor = [UIColor blackColor];
    titleLB.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:titleLB];
    
    
    // 创建左右两边的按钮
    NSArray *buttonTitleArray = @[@"取消",@"确定"];
    for (int i = 0; i <buttonTitleArray.count ; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(kSCREEN_W-but_W), 0, but_W, kTopViewHeight);
        [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_topView addSubview:button];
        
        button.tag = i;
        [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // 初始化pickerView
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, kTopViewHeight, kSCREEN_W, kPickerViewHeight-kTopViewHeight)];
    _pickerView.dataSource = self;
    _pickerView.delegate   = self;
    [self addSubview:_pickerView];
    
    _bgView = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    _bgView.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(hiddenPickerView)];
    [_bgView addGestureRecognizer: tap];
    
}




// 数据导入
- (void)createData
{
    // 设置默认值
    switch (self.pickerViewType) {
        case MBZPickerViewType_Normal:
        {
            // 正常情况
            
        }
            break;
        case MBZPickerViewType_LINKAGE:
        {
            // 联动数据处理
            // 1、所有的省数组
            NSArray *provincesArr   = [self provincesArray];
            // 2、第一个省下面的所有城市数组
            NSArray *citysArr       = [self citysArrayWithProvince:provincesArr[0]];
            // 3、第一个省内第一座城市下的所有区、县数组
            NSArray *areasArr       = [self areasArrayWithProvince:provincesArr[0] andCity:citysArr[0]];
            
            self.dataArr = [NSMutableArray array];
            self.dataArr = @[provincesArr,citysArr,areasArr].mutableCopy;
            _timeMutArr  = @[provincesArr[0],citysArr[0],areasArr[0]].mutableCopy;
            
            // 设置默认显示
//            [_pickerView selectRow:0 inComponent:0 animated:NO];
//            [_pickerView selectRow:0 inComponent:1 animated:NO];
//            [_pickerView selectRow:0 inComponent:2 animated:NO];
            
        }
            break;
        case MBZPickerViewType_YMDHMS:
        {
            //  YYYY-MM-DD HH:MM:SS
            // 默认年跨度
            
            // 获取 当前年月日时分秒
            NSString *nowYear   = [self nowYearTime];
            NSString *nowMonth  = [self nowMonthTime];
            NSString *nowDay    = [self nowDayTime];
            NSString *nowHour   = [self nowHourTime];
            NSString *nowMinute = [self nowMinuteTime];
            NSString *nowSecond = [self nowSecondTime];
            
            NSString *nowTime   = [NSString stringWithFormat:@"%@-%@-%@",nowYear,nowMonth,nowDay];
            NSLog(@"nowTime = %@,nowHour = %@,nowMinute = %@,nowSecond = %@",nowTime,nowHour,nowMinute,nowSecond);
            
            NSArray *timesArr   = [self allTimesArray];
            NSArray *hoursArr   = [self allHoursArray];
            NSArray *minutesArr = [self allMinutesArray];
            NSArray *secondsArr = [self allSecondsArray];
            
            self.dataArr = [NSMutableArray array];
            self.dataArr = @[timesArr,hoursArr,minutesArr,secondsArr].mutableCopy;
            // 获取的时间数组 设置默认初始值
            _timeMutArr  = @[timesArr[[timesArr indexOfObject:nowTime]],hoursArr[[hoursArr indexOfObject:nowHour]],minutesArr[[minutesArr indexOfObject:nowMinute]],secondsArr[[secondsArr indexOfObject:nowSecond]]].mutableCopy;
            
            // 设置默认显示
            [_pickerView selectRow:[timesArr indexOfObject:nowTime] inComponent:0 animated:NO];
            [_pickerView selectRow:[hoursArr indexOfObject:nowHour] inComponent:1 animated:NO];
            [_pickerView selectRow:[minutesArr indexOfObject:nowMinute] inComponent:2 animated:NO];
            [_pickerView selectRow:[secondsArr indexOfObject:nowSecond] inComponent:3 animated:NO];
            
            
            
            
        }
            break;
        case MBZPickerViewType_YMDHms:
        {
            // YYYY年MM月DD日 HH时mm分ss秒
            // 年月日
            NSString *nowYear   = [self nowYearTime];
            NSString *nowMonth  = [self nowMonthTime];
            NSString *nowDay    = [self nowDayTime];
            NSString *nowHour   = [self nowHourTime];
            NSString *nowMinute = [self nowMinuteTime];
            NSString *nowSecond = [self nowSecondTime];
            
            NSArray *yearsArr   = [self allYearsArray];
            NSArray *monthsArr  = [self allMonthsArray];
            NSArray *daysArr    = [self allDaysArrayWith:[nowYear integerValue] andMonth:[nowMonth integerValue]];
            NSArray *hoursArr   = [self allHoursArray];
            NSArray *minutesArr = [self allMinutesArray];
            NSArray *secondsArr = [self allSecondsArray];
            
            self.dataArr = [NSMutableArray array];
            self.dataArr = @[yearsArr,monthsArr,daysArr,hoursArr,minutesArr,secondsArr].mutableCopy;
            // 获取的时间数组 设置默认初始值
            _timeMutArr  = @[yearsArr[[yearsArr indexOfObject:nowYear]],monthsArr[[monthsArr indexOfObject:nowMonth]],daysArr[[daysArr indexOfObject:nowDay]],hoursArr[[hoursArr indexOfObject:nowHour]],minutesArr[[minutesArr indexOfObject:nowMinute]],secondsArr[[secondsArr indexOfObject:nowSecond]]].mutableCopy;
            
            // 设置默认显示
            [_pickerView selectRow:[yearsArr indexOfObject:nowYear] inComponent:0 animated:NO];
            [_pickerView selectRow:[monthsArr indexOfObject:nowMonth] inComponent:1 animated:NO];
            [_pickerView selectRow:[daysArr indexOfObject:nowDay] inComponent:2 animated:NO];
            [_pickerView selectRow:[hoursArr indexOfObject:nowHour] inComponent:3 animated:NO];
            [_pickerView selectRow:[minutesArr indexOfObject:nowMinute] inComponent:4 animated:NO];
            [_pickerView selectRow:[secondsArr indexOfObject:nowSecond] inComponent:5 animated:NO];
        }
            break;
        case MBZPickerViewType_HMS:
        {
            // 当前时间的时分秒
            NSString *nowHour   = [self nowHourTime];
            NSString *nowMinute = [self nowMinuteTime];
            NSString *nowSecond = [self nowSecondTime];
            // 时分秒
            NSArray *hoursArr   = [self allHoursArray];
            NSArray *minutesArr = [self allMinutesArray];
            NSArray *secondsArr = [self allSecondsArray];
            
            self.dataArr = [NSMutableArray array];
            self.dataArr = @[hoursArr,minutesArr,secondsArr].mutableCopy;
            // 获取的时间数组 设置默认初始值
            _timeMutArr  = @[hoursArr[[hoursArr indexOfObject:nowHour]],minutesArr[[minutesArr indexOfObject:nowMinute]],secondsArr[[secondsArr indexOfObject:nowSecond]]].mutableCopy;
            
            // 设置默认显示
            [_pickerView selectRow:[hoursArr indexOfObject:nowHour] inComponent:0 animated:NO];
            [_pickerView selectRow:[minutesArr indexOfObject:nowMinute] inComponent:1 animated:NO];
            [_pickerView selectRow:[secondsArr indexOfObject:nowSecond] inComponent:2 animated:NO];
            
        }
            break;
        case MBZPickerViewType_HMHM:
        {
            // 当前时间的时分
            NSString *nowHour   = [self nowHourTime];
            NSString *nowMinute = [self nowMinuteTime];
            // 时分
            NSArray *hoursArr   = [self allHoursArray];
            NSArray *minutesArr = [self allMinutesArray];
            
            self.dataArr = [NSMutableArray array];
            self.dataArr = @[hoursArr,minutesArr,hoursArr,minutesArr].mutableCopy;
            // 获取的时间数组 设置默认初始值
            _timeMutArr  = @[hoursArr[[hoursArr indexOfObject:nowHour]],minutesArr[[minutesArr indexOfObject:nowMinute]],hoursArr[[hoursArr indexOfObject:nowHour]],minutesArr[[minutesArr indexOfObject:nowMinute]]].mutableCopy;
            
            // 设置默认显示
            [_pickerView selectRow:[hoursArr indexOfObject:nowHour] inComponent:0 animated:NO];
            [_pickerView selectRow:[minutesArr indexOfObject:nowMinute] inComponent:1 animated:NO];
            [_pickerView selectRow:[hoursArr indexOfObject:nowHour] inComponent:2 animated:NO];
            [_pickerView selectRow:[minutesArr indexOfObject:nowMinute] inComponent:3 animated:NO];
        }
            break;
        default:
            break;
    }
    
}






// 按钮点击响应事件
- (void)buttonEvent:(UIButton *)button
{
    // 点击确定回调block
    if (button.tag == 1)
    {
        if (_block) {
            
            _block(_timeMutArr);
        }
    }
    [self hiddenPickerView];
}


// 显示 pickerView
- (void)showPickerView
{
    [self createData];
    [kMainWindow addSubview:_bgView];
    [kMainWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^
     {
         self.frame = CGRectMake(0, kSCREEN_H - kPickerViewHeight, kSCREEN_W, kPickerViewHeight);
         
     } completion:^(BOOL finished) {
         self.alpha    = 1;
         _bgView.alpha = 0.25;
     }];
    
}

// 隐藏pickerView
- (void)hiddenPickerView
{
    [UIView animateWithDuration:0.3 animations:^
     {
         self.alpha    = 0;
         _bgView.alpha = 0;
         self.frame    = CGRectMake(0, kSCREEN_H, kSCREEN_W, kPickerViewHeight);
     } completion:^(BOOL finished) {
         [self removeFromSuperview];
         [_bgView removeFromSuperview];
         
     }];
}

#pragma mark - UIPickerViewDelegate
// 设置每个component的宽度
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (self.pickerViewType) {
        case MBZPickerViewType_Normal:
        {
            if (self.widthArr.count < self.dataArr.count && self.widthArr.count != 0) {
                NSString *defaultStr = [NSString stringWithFormat:@"%.2f",kSCREEN_W / self.dataArr.count];
                for (int i = 0; i < self.dataArr.count; i++) {
                    [self.widthArr addObject:defaultStr];
                }
            }
        }
            return kSCREEN_W / (self.dataArr.count + 1);
            break;
        case MBZPickerViewType_LINKAGE:
        {
            return kSCREEN_W / 3;
        }
            break;
        case MBZPickerViewType_YMDHMS:
            self.widthArr = @[[NSString stringWithFormat:@"%.2f",kSCREEN_W * 0.45],[NSString stringWithFormat:@"%.2f",kSCREEN_W * 0.15],[NSString stringWithFormat:@"%.2f",kSCREEN_W * 0.15],[NSString stringWithFormat:@"%.2f",kSCREEN_W * 0.15]].mutableCopy;
            return [self.widthArr[component] integerValue];
            break;
        case MBZPickerViewType_YMDHms:
        {
            if (component == 0) {
                return kSCREEN_W / 6;
            }else {
                return kSCREEN_W / 7;
            }
        }
            break;
        case MBZPickerViewType_HMS:
            return kSCREEN_W / 5;
            break;
        case MBZPickerViewType_HMHM:
            return kSCREEN_W * 0.2;
            break;
        default:
            break;
    }
    
}
// 设置显示的title
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.dataArr[component] objectAtIndex:row];
    switch (self.pickerViewType) {
        case MBZPickerViewType_YMDHMS:
        {
            if (component == 1 || component == 2) {
                title = [NSString stringWithFormat:@"%@:",title];
            }
        }
            break;
        case MBZPickerViewType_YMDHms:
        {
            switch (component) {
                case 0:
                    title = [NSString stringWithFormat:@"%@年",title];
                    break;
                case 1:
                    title = [NSString stringWithFormat:@"%@月",title];
                    break;
                case 2:
                    title = [NSString stringWithFormat:@"%@日",title];
                    break;
                case 3:
                    title = [NSString stringWithFormat:@"%@时",title];
                    break;
                case 4:
                    title = [NSString stringWithFormat:@"%@分",title];
                    break;
                case 5:
                    title = [NSString stringWithFormat:@"%@秒",title];
                    break;
                default:
                    break;
            }

        }
            break;
        case MBZPickerViewType_HMS:
        {
            if (component != 2) {
                title = [NSString stringWithFormat:@"%@:",title];
            }
        }
            break;
        case MBZPickerViewType_HMHM:
        {
            if (component == 0 || component == 2) {
                title = [NSString stringWithFormat:@"%@:",title];
            }
            
        }
            break;
        default:
            break;
    }
    return title;
}

// 设置每一行的高度
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return _rowHeight;
}

#pragma mark - UIPickerViewDataSource
// 设置有几个 列表
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.dataArr.count;
}

// 设置每个列表对应的row的个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *arr = self.dataArr[component];
    return arr.count;
    
}


// 设置点击(即被选中)的那一行的数据
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView selectRow:row inComponent:component animated:YES];
    NSArray *data = self.dataArr[component];
    switch (self.pickerViewType) {
        case MBZPickerViewType_YMDHms:
        {
            NSArray *daysArr = [self allDaysArrayWith:[_timeMutArr[0] integerValue] andMonth:[_timeMutArr[1] integerValue]];
            if (component == 0) {
                daysArr = [self allDaysArrayWith:[data[row] integerValue] andMonth:[_timeMutArr[1] integerValue]];
            }else if (component == 1) {
                daysArr = [self allDaysArrayWith:[_timeMutArr[0] integerValue] andMonth:[data[row] integerValue]];
            }
            [self.dataArr replaceObjectAtIndex:2 withObject:daysArr];
            [pickerView reloadComponent:2];
            
        }
            break;
        case MBZPickerViewType_LINKAGE:
        {
            // 联动数据处理
            if (component == 0) {
                
                NSArray *cityArr    = [self citysArrayWithProvince:data[row]];
                [self.dataArr replaceObjectAtIndex:1 withObject:cityArr];
                [_timeMutArr replaceObjectAtIndex:1 withObject:cityArr[0]];
                NSArray *areasArr   = [self areasArrayWithProvince:data[row] andCity:cityArr[0]];
                [self.dataArr replaceObjectAtIndex:2 withObject:areasArr];
                [_timeMutArr replaceObjectAtIndex:2 withObject:areasArr[0]];
                [_pickerView selectRow:0 inComponent:1 animated:NO];
                [_pickerView selectRow:0 inComponent:2 animated:NO];
                [pickerView reloadAllComponents];
            }else if (component == 1) {
                NSArray *areasArr   = [self areasArrayWithProvince:_timeMutArr[0] andCity:data[row]];
                [self.dataArr replaceObjectAtIndex:2 withObject:areasArr];
                [_timeMutArr replaceObjectAtIndex:2 withObject:areasArr[0]];
                [_pickerView selectRow:0 inComponent:2 animated:NO];
                [pickerView reloadComponent:2];
                
            }
            
        }
            break;
        default:
            break;
    }
    [_timeMutArr replaceObjectAtIndex:component withObject:data[row]];
    
}

// 设置pickView 选中内容的显示框
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel)
    {
        pickerLabel = [[UILabel alloc] init];
        if (self.pickerViewType == MBZPickerViewType_HMHM) {
            if (component == 0 || component == 2) {
                [pickerLabel setTextAlignment:NSTextAlignmentRight];
            }else {
                [pickerLabel setTextAlignment:NSTextAlignmentLeft];
            }
        }else {
            [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [pickerLabel setFont:[UIFont systemFontOfSize:_font]];
        
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
    
}


#pragma mark ---- 年月日时分秒 当前时间
// 当前年
- (NSString *)nowYearTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearStr = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
    return yearStr;
}
// 当前月
- (NSString *)nowMonthTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM"];
    NSString *monthStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return monthStr;
}
// 当前天
- (NSString *)nowDayTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd"];
    NSString *dayStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return dayStr;
}
// 当前时
- (NSString *)nowHourTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH"];
    NSString *hourStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return hourStr;
}
// 当前分
- (NSString *)nowMinuteTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm"];
    NSString *minStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return minStr;
}
// 当前秒
- (NSString *)nowSecondTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"ss"];
    NSString *secondStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return secondStr;
}

#pragma mark ---- 年月日时分秒 数组集合
// 年数组
- (NSArray *)allYearsArray {
    NSMutableArray *yearMutArray = [NSMutableArray array];
    NSInteger nowYear = [[self nowYearTime] integerValue];
    for (NSInteger year = nowYear - _span; year <= nowYear + _span; year ++) {
        [yearMutArray addObject:[NSString stringWithFormat:@"%ld",year]];
    }
    return yearMutArray;
}
// 月数组
- (NSArray *)allMonthsArray {
    NSMutableArray *monthsMutArray = [NSMutableArray array];
    for (NSInteger month = 1; month <= 12; month ++)
    {
        NSString *monthStr = [NSString stringWithFormat:@"%ld",month];
        if (month < 10) monthStr = [NSString stringWithFormat:@"0%ld",month];
        [monthsMutArray addObject:monthStr];
    }
    return monthsMutArray;
}
// 年月日数组   YYYY-MM-DD
- (NSArray *)allTimesArray {
    NSArray *yearsArr   = [self allYearsArray];
    NSMutableArray *timesMutArr = [NSMutableArray array];
    for (id year in yearsArr) {
        NSArray *monthsArr  = [self allMonthsArray];
        for (id month in monthsArr) {
            NSArray *daysArr = [self allDaysArrayWith:[year integerValue] andMonth:[month integerValue]];
            for (id day in daysArr) {
                NSString *timeStr = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
                [timesMutArr addObject:timeStr];
            }
        }
    }
    
    return timesMutArr;
}

// 指定年月对应的天数数组
- (NSArray *)allDaysArrayWith:(NSInteger)year andMonth:(NSInteger)month {
    NSMutableArray *daysMutArray = [NSMutableArray array];
    NSInteger day = 30;
    if (month == 2) {
        if ([self isLeapYear:year]) {
            day = 29;
        } else {
            day = 28;
        }
    }else if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
        day = 31;
    }
    for (NSInteger i = 1; i <= day; i ++) {
        NSString *dayStr = [NSString stringWithFormat:@"%ld",i];
        if (i < 10) dayStr = [NSString stringWithFormat:@"0%ld",i];
        [daysMutArray addObject:dayStr];
    }
    return daysMutArray;
}
-(BOOL)isLeapYear:(NSInteger)year {
    
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return YES;
    }else {
        return NO;
    }
    return NO;
}
// 小时数组
- (NSArray *)allHoursArray {
    NSMutableArray *hoursMutArr = [NSMutableArray array];
    for (int i = 0; i < 24; i++) {
        NSString *hours = [NSString stringWithFormat:@"%d",i];
        if (i < 10) hours = [NSString stringWithFormat:@"0%d",i];
        [hoursMutArr addObject:hours];
    }
    return hoursMutArr;
}
// 分钟数组
- (NSArray *)allMinutesArray {
    NSMutableArray *minutesMutArr = [NSMutableArray array];
    for (int i = 0; i < 60; i ++){
        NSString *minutes = [NSString stringWithFormat:@"%d",i];
        if (i < 10) minutes = [NSString stringWithFormat:@"0%d",i];
        [minutesMutArr addObject:minutes];
    }
    return minutesMutArr;
}
// 秒数组
- (NSArray *)allSecondsArray {
    NSMutableArray *secondsMutArr = [NSMutableArray array];
    for (int i = 0; i < 60; i ++){
        NSString *second = [NSString stringWithFormat:@"%d",i];
        if (i < 10) second = [NSString stringWithFormat:@"0%d",i];
        [secondsMutArr addObject:second];
    }
    return secondsMutArr;
}


#pragma mark ---- 三级联动(只需更改内部数据解析方法即可)
// 省数组
- (NSArray *)provincesArray {
    NSArray *provinceArr = [self.dataDic allKeys];
    return provinceArr;
}

// 城市数组
- (NSArray *)citysArrayWithProvince:(NSString *)province {
    NSArray *provinceArr = [self.dataDic objectForKey:province];
    NSArray *cityArr     = [[provinceArr objectAtIndex:0] allKeys];
    return cityArr;
}

// 区、县数组
- (NSArray *)areasArrayWithProvince:(NSString *)province andCity:(NSString *)city {
    NSArray *provinceArr = [self.dataDic objectForKey:province];
    NSArray *areaArr     = [[provinceArr objectAtIndex:0] objectForKey:city];
    return areaArr;
}


@end
