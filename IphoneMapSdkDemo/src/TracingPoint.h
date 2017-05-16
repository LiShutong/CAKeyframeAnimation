//
//  TracingPoint.h
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TracingPoint : NSObject

/*!
 @brief 轨迹经纬度
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

//方向（角度）
@property (nonatomic) double angle;

//距离
@property (nonatomic) double distance;

//速度
@property (nonatomic) double speed;
@end
