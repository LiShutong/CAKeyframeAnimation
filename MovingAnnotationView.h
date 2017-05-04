//
//  MovingAnnotationView.h
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "TracingPoint.h"

@protocol MovingAnnotationViewAnimateDelegate <NSObject>

@optional
- (void)movingAnnotationViewAnimationFinished;

@end

@interface MovingAnnotationView : BMKAnnotationView

@property (nonatomic, weak) id<MovingAnnotationViewAnimateDelegate> animateDelegate;
@property (nonatomic, strong) UIImageView *imageView;


/*!
 @brief 添加动画
 @param points 轨迹点串，每个轨迹点为TracingPoint类型
 @param duration 动画时长，包括从上一个动画的终止点过渡到新增动画起始点的时间
 */
- (void)addTrackingAnimationForPoints:(NSArray *)points duration:(CFTimeInterval)duration;

@end
