//
//  BMapFooterView.m
//  biz
//
//  Created by mac on 2017/4/23.
//  Copyright © 2017年 1ge. All rights reserved.
//

#import "BMapFooterView.h"
#import "Masonry.h"
#import <MAMapKit/MAMapKit.h>


@interface BMapFooterView ()<MAMapViewDelegate,AMapSearchDelegate>{
    BOOL isFirstLocated;
}
@property MAMapView *myMapView;
@property(nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate;
@end

@implementation BMapFooterView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor greenColor];
        self.myMapView = [[MAMapView alloc] init];
        self.myMapView.userInteractionEnabled = YES;
        [self.myMapView setDelegate:self];
        self.myMapView.showsCompass = NO;
        // 不显示比例尺
        self.myMapView.showsScale = NO;
        // 地图缩放等级
        self.myMapView.zoomLevel = 16;
        self.myMapView.showsUserLocation = YES;
        self.myMapView.mapType = MAMapTypeStandard;
        self.myMapView.userTrackingMode = MAUserTrackingModeFollow; // 追踪用户位置.
        [self.contentView addSubview:self.myMapView];
        
        [self.myMapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
#pragma mark - Action
- (void)actionLocation
{
    [self.myMapView setCenterCoordinate:self.myMapView.userLocation.coordinate animated:YES];
}


#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    // 首次定位
    if (updatingLocation && !isFirstLocated) {
        [self.myMapView setCenterCoordinate:userLocation.location.coordinate];
        isFirstLocated = YES;
    } else {
        
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
   
    if (isFirstLocated) {
        // 范围移动时当前页面数重置
        self.currentLocationCoordinate = mapView.userLocation.coordinate;
        NSLog(@"MAUserTrackingMode change %f == %f",mapView.userLocation.coordinate.latitude,mapView.userLocation.coordinate.longitude);
        
    }
    
}

+ (void)setSelectedLocationWithLocation:(AMapPOI *)poi{
    BMapFooterView *map = [[BMapFooterView alloc] init];
    [map setSelectedLocationWithLocation:poi];
}

// 设置所选位置的地址位置
- (void)setSelectedLocationWithLocation:(AMapPOI *)poi
{
    [self.myMapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude,poi.location.longitude) animated:YES];
    NSLog(@"选中位置%@",poi.location);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

}


@end
