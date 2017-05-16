//
//  CACoordLayer.h
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface CACoordLayer : CALayer

@property (nonatomic, assign) BMKMapView * mapView;

//定义一个BMKAnnotation对象
@property (nonatomic, strong) BMKPointAnnotation *annotation;

@property (nonatomic) double mapx;

@property (nonatomic) double mapy;

@property (nonatomic) CGPoint centerOffset;

@end
