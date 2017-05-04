//
//  CACoordLayer.m
//

#import "CACoordLayer.h"

@implementation CACoordLayer

@dynamic mapx;
@dynamic mapy;

- (id)initWithLayer:(id)layer
{
    if ((self = [super initWithLayer:layer]))
    {
        if ([layer isKindOfClass:[CACoordLayer class]])
        {
            CACoordLayer * input = layer;
            self.mapx = input.mapx;
            self.mapy = input.mapy;
            [self setNeedsDisplay];
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([@"mapx" isEqualToString:key])
    {
        return YES;
    }
    if ([@"mapy" isEqualToString:key])
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (void)display
{
    CACoordLayer * layer = [self presentationLayer];
    BMKMapPoint mappoint = BMKMapPointMake(layer.mapx, layer.mapy);
    //根据得到的坐标值，将其设置为annotation的经纬度
    self.annotation.coordinate = BMKCoordinateForMapPoint(mappoint);
    //设置layer的位置，显示动画
    CGPoint center = [self.mapView convertCoordinate:BMKCoordinateForMapPoint(mappoint) toPointToView:self.mapView];
    self.position = center;
}

@end


