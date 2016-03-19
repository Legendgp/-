//
//  ViewController.m
//  后台定位

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *timeArray;
@end

@implementation ViewController
- (NSMutableArray *)array{
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}
- (NSMutableArray *)timeArray{
    if (!_timeArray) {
        _timeArray = [NSMutableArray array];
    }
    return _timeArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"后台定位数据持续上传";
    self.navigationController.navigationBar.barTintColor = [UIColor yellowColor];
    
    //location
    self.locationManager = [[CLLocationManager alloc] init];
    //该模式是抵抗程序在后台被杀，申明不能够被暂停
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        // 前后台同时定位
        [_locationManager requestAlwaysAuthorization];
    }
    //这里的定位精度为3公里级别，具体可按照自己需求修改
    _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    //tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    NSNotificationCenter *notication = [NSNotificationCenter defaultCenter];
    [notication addObserver:self selector:@selector(notice:) name:@"location" object:nil];
}
- (void)notice:(NSNotification *)notice
{
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"location";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    CLLocation *location = [_array[indexPath.row] lastObject];
    float latitudeMe = location.coordinate.latitude;
    float longitudeMe = location.coordinate.longitude;
    cell.textLabel.text = [NSString stringWithFormat:@"%f--%f", latitudeMe, longitudeMe];
    cell.detailTextLabel.text = _timeArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"1"];
    return cell;
}

//当用户位置改变时，系统会自动调用，这里必须写一点儿代码，否则后台时间刷新不管用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"位置改变，必须做点儿事情才能刷新后台时间");
    //获取当前的位置
    CLLocation *location = [locations lastObject];
    float latitudeMe = location.coordinate.latitude;
    float longitudeMe = location.coordinate.longitude;
    NSLog(@"%f,%f",latitudeMe, longitudeMe);
    [self.array addObject:locations];
    
    //当前时间
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [self.timeArray addObject: currentTime];
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification postNotificationName:@"location" object:self userInfo:nil];
}
@end
