//
//  IndoorDemoViewController.mm
//  IphoneMapSdkDemo
//
//  Created by wzy on 16/5/23.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "IndoorDemoViewController.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "PromptInfo.h"
#import "RouteAnnotation.h"

@implementation BMKIndoorFloorCell

@synthesize floorTitleLabel = _floorTitleLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    BMKIndoorFloorCell *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    cell.backgroundColor = [UIColor clearColor];

    _floorTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
    [_floorTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_floorTitleLabel setFont:[UIFont systemFontOfSize:14]];
    [_floorTitleLabel setTextColor:[UIColor blackColor]];
    [cell addSubview:_floorTitleLabel];
    
    UIView *selectBg = [[UIView alloc] initWithFrame:cell.frame];
    selectBg.backgroundColor = [UIColor colorWithRed:50.0/255 green:120.0/255.0 blue:1 alpha:0.8];
    cell.selectedBackgroundView = selectBg;
    
    return cell;
}


@end


@interface IndoorDemoViewController ()<UITableViewDelegate, UITableViewDataSource, BMKPoiSearchDelegate, BMKRouteSearchDelegate> {
    UITableView *_floorTableView;//显示楼层条
    BMKBaseIndoorMapInfo *_indoorMapInfoFocused;//存储当前聚焦的室内图
    BMKPoiSearch *_search;
    BMKRouteSearch *_routeSearch;
}

@end


@implementation IndoorDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    _mapView.zoomLevel = 19;
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(39.917, 116.379);
    _mapView.baseIndoorMapEnabled = YES;//打开室内图
    _search = [[BMKPoiSearch alloc] init];
    _routeSearch = [[BMKRouteSearch alloc] init];
    
    //添加室内路线检索入口
    UIBarButtonItem *customRightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"室内路线" style:UIBarButtonItemStyleBordered target:self action:@selector(indoorRoutePlanSearch)];
    self.navigationItem.rightBarButtonItem = customRightBarButtonItem;

    
    _keyworkField.delegate = self;
    _keyworkField.text = @"餐厅";
    _searchView.hidden = YES;
    
    _indoorMapInfoFocused = [[BMKBaseIndoorMapInfo alloc] init];
    
    //添加楼层条
    _floorTableView = [[UITableView alloc] init];
    CGFloat h = 150;
    CGFloat y = self.view.frame.size.height - h - 100;
    _floorTableView.frame = CGRectMake(10, y, 35, h);
    _floorTableView.alpha = 0.8;
    _floorTableView.layer.borderWidth = 1;
    _floorTableView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.7].CGColor;
    _floorTableView.delegate = self;
    _floorTableView.dataSource = self;
    _floorTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _floorTableView.hidden = YES;
    [self.view addSubview:_floorTableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard)];
    tap.cancelsTouchesInView = NO;//添加自定义手势时，需设置，否则影响地图的操作
    tap.delaysTouchesEnded = NO;//添加自定义手势时，需设置，否则影响地图的操作
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _search.delegate = self;
    _routeSearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _search.delegate = nil;
    _routeSearch.delegate = nil;
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

///发起室内检索
- (IBAction)indoorSearchAction:(id)sender {
    NSArray *annotationArray = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:annotationArray];
    NSArray *overlayArray = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:overlayArray];
    BMKPoiIndoorSearchOption *option = [[BMKPoiIndoorSearchOption alloc] init];
    option.indoorId = _indoorMapInfoFocused.strID;
    option.keyword = _keyworkField.text;
    option.pageIndex = 0;
    option.pageCapacity = 20;
    BOOL flag = [_search poiIndoorSearch:option];
    if (!flag) {
        [PromptInfo showText:@"室内检索发送失败"];
    }
}

///发起室内路线规划检索
- (IBAction)indoorRoutePlanSearch {
    
    BMKIndoorPlanNode* start = [[BMKIndoorPlanNode alloc]init];
    start.floor = @"F1";
    start.pt = CLLocationCoordinate2DMake(39.916634, 116.379916);
    BMKIndoorPlanNode* end = [[BMKIndoorPlanNode alloc]init];
    end.floor = @"F5";
    end.pt = CLLocationCoordinate2DMake(39.917312, 116.378919);
    BMKIndoorRoutePlanOption* indoorRouteSearchOption = [[BMKIndoorRoutePlanOption alloc]init];
    indoorRouteSearchOption.from = start;
    indoorRouteSearchOption.to = end;
    
    BOOL flag = [_routeSearch indoorRoutePlanSearch:indoorRouteSearchOption];
    indoorRouteSearchOption = nil;
    if (flag) {
        NSLog(@"室内路线检索发送成功");
    }
    else {
        NSLog(@"室内路线检索发送失败");
    }
}

///隐藏键盘
- (void)hiddenKeyBoard {
    [_keyworkField resignFirstResponder];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BMKIndoorFloorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FloorCell"];
    if (cell == nil) {
        cell = [[BMKIndoorFloorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FloorCell"];
    }
    
    NSString *title = [NSString stringWithFormat:@"%@",[_indoorMapInfoFocused.arrStrFloors objectAtIndex:indexPath.row]];
    cell.floorTitleLabel.text = title;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _indoorMapInfoFocused.arrStrFloors.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进行楼层切换
    NSArray *annotationArray = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:annotationArray];
    NSArray *overlayArray = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:overlayArray];
    BMKSwitchIndoorFloorError error = [_mapView switchBaseIndoorMapFloor:[_indoorMapInfoFocused.arrStrFloors objectAtIndex:indexPath.row] withID:_indoorMapInfoFocused.strID];
    if (error == BMKSwitchIndoorFloorSuccess) {
        [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        NSLog(@"切换楼层成功");
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - BMKMapViewDelegate
/**
 *地图进入/移出室内图会调用此接口
 *@param mapview 地图View
 *@param flag  YES:进入室内图; NO:移出室内图
 *@param info 室内图信息
 */
-(void)mapview:(BMKMapView *)mapView baseIndoorMapWithIn:(BOOL)flag baseIndoorMapInfo:(BMKBaseIndoorMapInfo *)info
{
    BOOL showIndoor = NO;
    if (flag) {//进入室内图
        if (info != nil && info.arrStrFloors.count > 0) {
            _indoorMapInfoFocused.strID = info.strID;
            _indoorMapInfoFocused.strFloor = info.strFloor;
            _indoorMapInfoFocused.arrStrFloors = info.arrStrFloors;
            
            [_floorTableView reloadData];
            NSInteger index = [info.arrStrFloors indexOfObject:info.strFloor];
            [_floorTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            
            showIndoor = YES;
        }
    }

    _floorTableView.hidden = !showIndoor;
    _searchView.hidden = !showIndoor;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        return [(RouteAnnotation*)annotation getRouteAnnotationView:view];
    }
    return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}


#pragma mark - BMKPoiSearchDelegate
/**
 *返回POI室内搜索结果
 *@param searcher 搜索对象
 *@param poiIndoorResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiIndoorResult:(BMKPoiSearch *)searcher result:(BMKPoiIndoorResult *)poiIndoorResult errorCode:(BMKSearchErrorCode)errorCode {
    NSLog(@"onGetPoiIndoorResult errorcode: %d", errorCode);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //成功获取结果
        for (BMKPoiIndoorInfo *info in poiIndoorResult.poiIndoorInfoList) {
            NSLog(@"name: %@  uid: %@  floor: %@", info.name, info.uid, info.floor);
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
            annotation.title = info.name;
            annotation.coordinate = info.pt;
            [_mapView addAnnotation:annotation];
        }
        [PromptInfo showText:[NSString stringWithFormat:@"室内检索成功，共获取%d条信息", (int)poiIndoorResult.poiIndoorInfoList.count]];
    } else {
        //检索失败
        [PromptInfo showText:@"室内检索失败"];
    }
}


#pragma mark - BMKRouteSearchDelegate

/**
 *返回室内路线搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKIndoorRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetIndoorRouteResult:(BMKRouteSearch*)searcher result:(BMKIndoorRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetIndoorRouteResult errorcode:%d", (int)error);
    [self clearMapView];
    if (error == BMK_SEARCH_NO_ERROR) {
        for (BMKIndoorRouteLine *plan in result.routes) {
            // 计算路线方案中的路段数目
            NSInteger size = [plan.steps count];
            NSInteger planPointCounts = 0;
            
            // 添加起点标注
            RouteAnnotation *startItem = [[RouteAnnotation alloc]init];
            startItem.coordinate = plan.starting.location;
            startItem.title = @"起点";
            startItem.type = 0;
            [_mapView addAnnotation:startItem]; // 添加起点标注
            
            // 添加起点标注
            RouteAnnotation *endItem = [[RouteAnnotation alloc]init];
            endItem.coordinate = plan.terminal.location;
            endItem.title = @"终点";
            endItem.type = 1;
            [_mapView addAnnotation:endItem]; // 添加起点标注
            
            for (NSInteger i = 0; i < size; i++) {
                BMKIndoorRouteStep* step = [plan.steps objectAtIndex:i];
                
                //添加annotation节点
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = step.entrace.location;
                item.title = step.instructions;
                item.type = 6;
                [_mapView addAnnotation:item];
                
                //轨迹点总数累计
                planPointCounts += step.pointsCount;
            }
            
            //轨迹点
            BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
            NSInteger i = 0;
            for (NSInteger j = 0; j < size; j++) {
                BMKIndoorRouteStep* step = [plan.steps objectAtIndex:j];
                for(NSInteger k = 0; k < step.pointsCount ; k++) {
                    temppoints[i].x = step.points[k].x;
                    temppoints[i].y = step.points[k].y;
                    i++;
                }
            }
            // 通过points构建BMKPolyline
            BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:i];
            [_mapView addOverlay:polyLine]; // 添加路线overlay
            [self mapViewFitPolyLine:polyLine];
            delete []temppoints;
            break;
        }
    } else {
        //检索失败
        [PromptInfo showText:@"室内路线规划检索失败"];
    }
}

#pragma mark - 私有

- (void)clearMapView {
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
}

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}
@end
