//
//  MBZPickerView.h
//  MBZPickerView
//
//  Created by viktor on 17/4/10.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MBZPickerViewType) {
    MBZPickerViewType_Normal,
    MBZPickerViewType_LINKAGE,
    MBZPickerViewType_YMDHMS,
    MBZPickerViewType_YMDHms,
    MBZPickerViewType_HMS,
    MBZPickerViewType_HMHM
};
typedef  void(^MBZPickerViewBlock)(NSMutableArray *dateMutArr);

@interface MBZPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic,copy) MBZPickerViewBlock block;

/** 当前弹出视图的显示状态(YES 处于弹出状态 NO 隐藏状态) */
@property (nonatomic) BOOL currentPickState;

@property (nonatomic, assign) CGFloat font;                     // 字体大小，默认24
@property (nonatomic, assign) NSInteger span;                   // 年时间跨度(与当前年的前后跨度)
@property (nonatomic, assign) NSInteger rowHeight;

/** 带时间的默认初始化方式 */
-(instancetype)initWithTitle:(NSString *)titleStr withPickerViewType:(NSInteger)type;
/** 默认方式的初始化方式(每列数据不需要对应变动) */
-(instancetype)initWithTitle:(NSString *)titleStr withPickerViewType:(NSInteger)type andData:(NSArray *)dataArr;
/** 联动类型的初始化方式(类似于区域,三层结构) */
-(instancetype)initWithTitle:(NSString *)titleStr withData:(NSDictionary *)dataDic;
/** 显示PickerView */
-(void)showPickerView;

/** 隐藏PickerView */
-(void)hiddenPickerView;

@end
