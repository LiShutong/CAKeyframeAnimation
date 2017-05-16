//
//  SportPathDemoViewController.m
//  IphoneMapSdkDemo
//
//  Created by wzy on 16/6/15.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "SportPathDemoViewController.h"
#import "MovingAnnotationView.h"
#import "TracingPoint.h"
#import "JSONKit.h"

@interface SportPathDemoViewController ()<MovingAnnotationViewAnimateDelegate> {
    BMKPointAnnotation *sportAnnotation;

    NSMutableArray *_tracking;
}

@end

@implementation SportPathDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    _mapView.zoomLevel = 14;
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(40.056898, 116.307626);
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放

    //初始化轨迹点
    [self initSportNodes];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

//初始化轨迹点
- (void)initSportNodes {
    _tracking = [NSMutableArray array];
    //读取数据
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sport_path" ofType:@"json"]];
    if (jsonData) {
        NSArray *array = [jsonData objectFromJSONData];
        NSInteger count = array.count;
        for (NSDictionary *dic in array) {
            TracingPoint * tp = [[TracingPoint alloc] init];
            tp.coordinate = CLLocationCoordinate2DMake([dic[@"lat"] doubleValue], [dic[@"lon"] doubleValue]);
            tp.angle = [dic[@"angle"] doubleValue];
            [_tracking addObject:tp];
        }
    }
}

//开始
- (void)start {
    //show route
    NSInteger sportNodeNum = [_tracking count];
    CLLocationCoordinate2D paths[sportNodeNum];
    for (NSInteger i = 0; i < sportNodeNum; i++) {
        TracingPoint * tp = _tracking[i];
        paths[i] = tp.coordinate;
    }
    BMKPolyline *path = [BMKPolyline polylineWithCoordinates:paths count:sportNodeNum];
    [_mapView addOverlay:path];
    
    //show annotation
    sportAnnotation = [[BMKPointAnnotation alloc] init];
    TracingPoint * start = [_tracking firstObject];
    sportAnnotation.coordinate = start.coordinate;
    sportAnnotation.title = @"sport node";
    [_mapView addAnnotation:sportAnnotation];
}

//runing
- (void)running {
    /* Find annotation view for car annotation. */
    MovingAnnotationView * annotationView = (MovingAnnotationView *)[_mapView viewForAnnotation:sportAnnotation];
    
    [annotationView addTrackingAnimationForPoints:_tracking duration:300];
}

- (void)movingAnnotationViewAnimationFinished {
    NSLog(@"animate finished");
    [self running];
}

#pragma mark - BMKMapViewDelegate

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    [self start];
}

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0.0 green:0.5 blue:0.0 alpha:0.6];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"view.annotation,%f,%f",sportAnnotation.coordinate.latitude,sportAnnotation.coordinate.longitude);
}

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    static NSString *reuseIndetifier = @"sportsAnnotation";
    MovingAnnotationView *annotationView = (MovingAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
    if (annotationView == nil)
    {
        annotationView = [[MovingAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        annotationView.animateDelegate = self;
    }
    
    UIImage *imge = [UIImage imageNamed:@"sportarrow.png"];
    annotationView.image = imge;
    CGPoint centerPoint= CGPointZero;
    [annotationView setCenterOffset:centerPoint];
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    [self running];
}

@end
