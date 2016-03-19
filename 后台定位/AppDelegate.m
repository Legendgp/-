//
//  AppDelegate.m
//  后台定位
/*
 如果想在后台继续做其他事情
 */
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
@interface AppDelegate ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *v = [[ViewController alloc] init];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:v];
    self.window.rootViewController = navC;
    [self.window makeKeyAndVisible];

    //iOS9新特性：将允许出现这种场景：同一app中多个location manager：一些只能在前台定位，另一些可在后台定位（并可随时禁止其后台定位）。
    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    return YES;
}
#pragma mark ------ 挂起(你可以重写这个方法，做挂起前的工作，比如关闭网络，保存数据,当你的程序被挂起后他不会在后台运行。)
- (void)applicationWillResignActive:(UIApplication *)application {
}

#pragma mark ------ 一旦程序进入后台就会掉用, 当用户从台前状态转入后台时，调用此方法。使用此方法来释放资源共享，保存用户数据，无效计时器，并储存足够的应用程序状态信息的情况下被终止后，将应用 程序恢复到目前的状态。如果您的应用程序支持后台运行，这种方法被调用，否则调用applicationWillTerminate：用户退出
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        [_locationManager stopUpdatingLocation];
        [_locationManager startMonitoringSignificantLocationChanges];
    }else{
        NSLog(@"Significant location change monitoring is not available.");
    }
    
    //可以通过backgroundTimeRemaining查看应用程序后台停留的时间
    NSLog(@"backgroundTimeRemaining = %f",application.backgroundTimeRemaining);
    
    //一个后台任务标识符
    __block UIBackgroundTaskIdentifier background_task;
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        //如果系统觉得我们还是运行了太久，将执行这个程序块，并停止运行应用程序
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            /*
             做一些事情
             */
            sleep(1);
        }
    });
}


#pragma mark ----- 当应用在后台状态，将要进行动前台运行状态时，会调用此方法。如果应用不在后台状态，而是直接启动，则不会回调此方法。
- (void)applicationWillEnterForeground:(UIApplication *)application {
}

#pragma mark ----- 复原(此你可以通过之前挂起前保存的数据来恢复你的应用程序)
#warning 注意：应用程序在启动时，在调用了 applicationDidFinishLaunching 方法之后也会调用 applicationDidBecomeActive 方法，所以你要确保你的代码能够分清复原与启动，避免出现逻辑上的bug。
- (void)applicationDidBecomeActive:(UIApplication *)application {
}

#pragma mark ----- 当应用可用内存不足时，会调用此方法，在这个方法中，应该尽量去清理可能释放的内存。如果实在不行，可能会被强行退出应用。
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
