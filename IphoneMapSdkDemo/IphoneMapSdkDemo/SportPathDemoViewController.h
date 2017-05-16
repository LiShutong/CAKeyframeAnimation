//
//  SportPathDemoViewController.h
//  IphoneMapSdkDemo
//
//  Created by wzy on 16/6/15.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#ifndef SportPathDemoViewController_h
#define SportPathDemoViewController_h
#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
@interface SportPathDemoViewController :  UIViewController<BMKMapViewDelegate>

@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@end

#endif /* SportPathDemoViewController_h */
