//
//  ViewController.m
//  MBZPickerView
//
//  Created by viktor on 17/4/10.
//
//

#import "ViewController.h"
#import "MBZPickerView.h"

@interface ViewController ()

@property (nonatomic, strong) MBZPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *showLb;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

// 1个列表展示
- (IBAction)pickViewType1:(id)sender {
    
    NSArray *dataArr = @[@"圆通速递",@"中通快递",@"EMS经济快递",@"EMS",@"德邦快递",@"宅急送",@"韵达快递",@"天天快递",@"百世物流",@"德邦物流",@"顺丰速运",@"申通快递",@"国通快递"];
    MBZPickerView *pickerView = [[MBZPickerView alloc]initWithTitle:@"1个列表展示" withPickerViewType:MBZPickerViewType_Normal andData:dataArr];
    pickerView.font = 20.0;
    [self.view addSubview:pickerView];
    __weak typeof(self) weakSelf = self;
    [pickerView showPickerView];
    pickerView.block = ^(NSMutableArray *dateMutArr)
    {
        weakSelf.showLb.text = [NSString stringWithFormat:@"%@",dateMutArr[0]];
    };
    
}

// 多个列表展示
- (IBAction)pickViewType2:(id)sender {

    NSArray *dataArr = @[@[@"EMS",@"德邦快递",@"宅急送",@"韵达快递",@"天天快递",@"顺丰速运",@"申通快递",@"国通快递"],
                         @[@"圆通速递",@"中通快递",@"EMS经济快递"],
                         @[@"百世物流",@"德邦物流"],];
    MBZPickerView *pickerView = [[MBZPickerView alloc]initWithTitle:@"多个列表展示" withPickerViewType:MBZPickerViewType_Normal andData:dataArr];
    pickerView.font = 15.0;
    pickerView.rowHeight = 30.0;
    [self.view addSubview:pickerView];
    __weak typeof(self) weakSelf = self;
    [pickerView showPickerView];
    pickerView.block = ^(NSMutableArray *dateMutArr)
    {
        NSString *dataStr = dateMutArr[0];
        for (int i = 1; i < dateMutArr.count; i ++) {
            dataStr = [NSString stringWithFormat:@"%@:%@",dataStr,dateMutArr[i]];
        }
        weakSelf.showLb.text = dataStr;
    };
    
    
}

// 时间  YYYY-MM-DD HH:MM:SS
- (IBAction)pickViewType3:(id)sender {
    
    MBZPickerView *pickerView = [[MBZPickerView alloc]initWithTitle:@"YYYY-MM-DD HH:MM:SS" withPickerViewType:MBZPickerViewType_YMDHMS];
    pickerView.span = 5;
    [self.view addSubview:pickerView];
    [pickerView showPickerView];
    __weak typeof(self) weakSelf = self;
    pickerView.block = ^(NSMutableArray *dateMutArr)
    {
        weakSelf.showLb.text = [NSString stringWithFormat:@"%@ %@:%@:%@",dateMutArr[0],dateMutArr[1],dateMutArr[2],dateMutArr[3]];
    };
    
}

// 时间  YYYY年MM月DD日 HH时mm分ss秒
- (IBAction)pickViewType4:(id)sender {
    MBZPickerView *pickerView = [[MBZPickerView alloc]initWithTitle:@"YYYY年MM月DD日 HH时mm分ss秒" withPickerViewType:MBZPickerViewType_YMDHms];
    pickerView.span = 10;
    pickerView.font = 15.0;
    pickerView.rowHeight = 30;
    [self.view addSubview:pickerView];
    [pickerView showPickerView]; 
    __weak typeof(self) weakSelf = self;
    pickerView.block = ^(NSMutableArray *dateMutArr)
    {
        weakSelf.showLb.text = [NSString stringWithFormat:@"%@年%@月%@日 %@时%@分%@秒",dateMutArr[0],dateMutArr[1],dateMutArr[2],dateMutArr[3],dateMutArr[4],dateMutArr[5]];
    };
    
}

// 时间(双选择)  HH:MM  HH:MM
- (IBAction)pickViewType5:(id)sender {
    MBZPickerView *pickerView = [[MBZPickerView alloc]initWithTitle:@"HH:MM  HH:MM" withPickerViewType:MBZPickerViewType_HMHM];
    [self.view addSubview:pickerView];
    [pickerView showPickerView];
    __weak typeof(self) weakSelf = self;
    pickerView.block = ^(NSMutableArray *dateMutArr)
    {
        weakSelf.showLb.text = [NSString stringWithFormat:@"%@:%@ -- %@:%@",dateMutArr[0],dateMutArr[1],dateMutArr[2],dateMutArr[3]];
    };
    
}

// 省市区 三级联动选择
- (IBAction)pickViewType6:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    MBZPickerView *pickerView = [[MBZPickerView alloc]initWithTitle:@"省市区 三级联动选择" withData:dic];
    pickerView.font = 15.0;
    pickerView.rowHeight = 30;
    [self.view addSubview:pickerView];
    [pickerView showPickerView];
    __weak typeof(self) weakSelf = self;
    pickerView.block = ^(NSMutableArray *dateMutArr)
    {
        weakSelf.showLb.text = [NSString stringWithFormat:@"%@--%@--%@",dateMutArr[0],dateMutArr[1],dateMutArr[2]];
    };
    
    
}


- (IBAction)pickViewType7:(id)sender {
    
    
}



















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
