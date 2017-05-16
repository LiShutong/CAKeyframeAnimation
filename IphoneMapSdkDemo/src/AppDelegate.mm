//
//  AppDelegate.m
//  BaiduMapSdkSrc
//
//  Created by baidu on 13-3-21.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "RootViewController.h"

BMKMapManager* _mapManager;
@implementation AppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	// 要使用百度地图，请先启动BaiduMapManager
	_mapManager = [[BMKMapManager alloc]init];
    
    /**
     *百度地图SDK所有接口均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
     *默认是BD09（BMK_COORDTYPE_BD09LL）坐标. 
     *如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
     */
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }
    
    BOOL ret = [_mapManager start:@"QFlGVMe0huh3m2fPG2HQQaaGr1Yl8YP7" generalDelegate:self];
	if (!ret) {
		NSLog(@"manager start failed!");
	}
    
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

@end
