//
//  BMapViewController.m
//  biz
//
//  Created by mac on 2017/4/23.
//  Copyright © 2017年 1ge. All rights reserved.
//

#import "BMapViewController.h"
#import "BSearchHeaderView.h"
#import "BMapFooterView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>
#import "UIColor+Helper.h"
#import "Masonry.h"

@interface BMapViewController ()<UISearchBarDelegate,AMapSearchDelegate,MAMapViewDelegate>
{
    // Poi搜索结果数组
    NSMutableArray *_searchPoiArray;
    BOOL isFirstLocated;
}
@property(nonatomic,strong) AMapSearchAPI *searchAPI;
@property (nonatomic, strong) UISearchBar *mySearchBar;
@property(nonatomic,strong)UIButton *currentLocationBtn;
@property(nonatomic,strong)UIImageView *centerCallOutImageView;
@property (nonatomic) MAMapView *myMapView;
@property  AMapPOI *selectedPoi;

@end

@implementation BMapViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewStyle)style{
    if (self = [super initWithStyle:style]) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedPoi = [AMapPOI new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.mySearchBar.placeholder = @"eeee";
    self.mySearchBar.delegate = self;
    [self.mySearchBar sizeToFit];
    
    UIView *searchTextField = nil;
            if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
                self.mySearchBar.barTintColor = [UIColor hexStringToColor:@"27dcfb"];
                searchTextField = [self.mySearchBar valueForKey:@"_searchField"];
            }else{
                for (UIView *subView in self.mySearchBar.subviews) {
                    if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                        searchTextField = subView;
                        break;
                    }
                }
            }
            if (searchTextField) {
    //            searchTextField.backgroundColor = [UIColor hexStringToColor:@"27dcfb"];
    //            searchTextField.layer.masksToBounds = YES;
    //            searchTextField.layer.cornerRadius = 3.0f;
    //            searchTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    //            searchTextField.layer.borderWidth = 0.5;
                ((UITextField *)searchTextField).leftView.hidden = NO;
                ((UITextField *)searchTextField).leftViewMode = UITextFieldViewModeAlways;
    //            ((UITextField *)searchTextField).textColor = [UIColor whiteColor];
    //            [((UITextField *)searchTextField) setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            }
    //        [self.mySearchBar setImage:[UIImage imageNamed:@"search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
            [self.mySearchBar setImage:[UIImage imageNamed:@"cuo"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    
    UIImage* searchBarBg = [self GetImageWithColor:[UIColor hexStringToColor:@"F1EEEF"] andHeight:32.0f];
    [self.mySearchBar  setBackgroundImage:searchBarBg];
    [self.view addSubview:self.mySearchBar];
    
    _searchPoiArray = [NSMutableArray array];
    self.searchAPI = [[AMapSearchAPI alloc] init];
    self.searchAPI.delegate = self;
    self.tableView.tableFooterView = self.myMapView;
    [self.tableView registerClass:[BSearchHeaderView class] forCellReuseIdentifier:@"BSearchHeaderView"];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[BMapFooterView class] forHeaderFooterViewReuseIdentifier:@"BMapFooterView"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:(UIBarButtonItemStylePlain) target:self action:@selector(determineSendLocation)];

}
- (UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (MAMapView *)myMapView{
    if (!_myMapView) {
        self.myMapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-200)];
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
        self.myMapView.compassOrigin = CGPointMake(self.myMapView.compassOrigin.x, 22);
        self.myMapView.scaleOrigin = CGPointMake(self.myMapView.scaleOrigin.x, 22);
        
        [self initControls];
    }
    return _myMapView;
}

-(void)initControls{
    
    _centerCallOutImageView=[UIImageView new];
    [_centerCallOutImageView setImage:[UIImage imageNamed:@"Group_3"]];
    _centerCallOutImageView.frame = CGRectMake(self.myMapView.center.x - 9, self.myMapView.center.y - 12, 18, 24);
    [self.myMapView addSubview:self.centerCallOutImageView];
    
    self.currentLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.currentLocationBtn.frame = CGRectMake(10, CGRectGetHeight(self.myMapView.bounds)-120, 44, 44);
    self.currentLocationBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;//
    [self.currentLocationBtn setImage:[UIImage imageNamed:@"location_back_icon"] forState:UIControlStateNormal];
    [self.currentLocationBtn setImage:[UIImage imageNamed:@"location_blue_icon"] forState:UIControlStateSelected];
    [self.currentLocationBtn addTarget:self action:@selector(locateAction) forControlEvents:UIControlEventTouchUpInside];
    [self.myMapView addSubview:self.currentLocationBtn];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchPoiArray.count == 0 ? 1 : _searchPoiArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _searchPoiArray.count == 0 ? 200 : 54;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001F;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchPoiArray.count == 0) {
        BSearchHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:@"BSearchHeaderView" forIndexPath:indexPath];
        
        
        // Configure the cell...
        //    cell.textLabel.text = @"UITableViewCell";
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" ];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
        }
        AMapPOI *obj = _searchPoiArray[indexPath.row];
        // Configure the cell...
        cell.textLabel.text = obj.name;
        cell.imageView.image = [UIImage imageNamed:@"weizhi"];
        cell.detailTextLabel.text = obj.address;
        return cell;
    }
}
#pragma mark - ***** 解决tableview的分割线短一截
- (void)viewDidLayoutSubviews
{
    
    if ([self.tableView respondsToSelector:@selector
         (setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    
    if ([self.tableView respondsToSelector:@selector
         (setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}
#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error;{
    NSLog(@"%@%@",request,error);
}
#pragma mark - AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    // 搜索结束后重新设置delegate
    _searchAPI.delegate = self;
    NSLog(@"onPOISearchDone:%@",_searchAPI.delegate);
    [_searchPoiArray removeAllObjects];
    if (response.pois.count == 0) {
        
    }
    else {
        [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
          
            [_searchPoiArray addObject:obj];
            
        }];
        [self.tableView reloadData];
    }
}

// 通过关键字搜索地理位置
- (void)searchPoiBySearchString:(NSString *)searchString
{
    //POI关键字搜索
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = searchString;
    //    request.city = @"北京";
    request.cityLimit = YES;
    request.page = 1;
    request.requireSubPOIs      = YES;
    [_searchAPI AMapPOIKeywordsSearch:request];
}

#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.mySearchBar .showsCancelButton = YES;
    searchBar.translucent = YES;
    return YES;
}
#pragma mark -----------------搜索栏代理--------------------
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // 修改UISearchBar右侧的取消按钮文字颜色及背景图片
    for (id searchbuttons in [[searchBar subviews][0]subviews]) //只需在此处修改即可
        if ([searchbuttons isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            // 修改文字颜色
            //            CGRect rect = cancelButton.frame;
            //            rect.size = CGSizeMake(60, 48);
            //            cancelButton.frame = rect;
            //            [cancelButton setBackgroundImage:[UIImage imageNamed:@"queding"] forState:UIControlStateNormal];
            cancelButton.layer.cornerRadius = 3.0;
            [cancelButton.layer setMasksToBounds:YES];
            [cancelButton setTitle:@"确定"forState:UIControlStateNormal];
            cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            cancelButton.backgroundColor = [UIColor hexStringToColor:@"830062"];
        }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"textDidChange: %@", searchText);
    if(0 == searchText.length)
    {
        return ;
        
    }
    [_searchPoiArray removeAllObjects];
    [self searchUserWithStr:searchText];
    [self.tableView reloadData];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked: %@", searchBar.text);
    self.mySearchBar .showsCancelButton = NO;
    [searchBar resignFirstResponder]; //searchBar失去焦点
    UIButton *cancelBtn = [searchBar valueForKey:@"cancelButton"]; //首先取出cancelBtn
    cancelBtn.enabled = YES; //把enabled设置为yes
    [self searchUserWithStr:searchBar.text];
    [self.tableView reloadData];
   
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED{
    NSLog(@"取消按钮");
    [searchBar resignFirstResponder]; //searchBar失去焦点
    self.mySearchBar .showsCancelButton = NO;
    UIButton *cancelBtn = [searchBar valueForKey:@"cancelButton"]; //首先取出cancelBtn
    cancelBtn.enabled = YES; //把enabled设置为yes
    [self searchUserWithStr:searchBar.text];
    [self.tableView reloadData];
}
- (void)searchUserWithStr:(NSString *)string{
    NSString *strippedStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _searchAPI.delegate = self;
    [self searchPoiBySearchString:strippedStr];
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    BSearchHeaderView *searchView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BSearchHeaderView"];
//    searchView.searchBlock = ^(NSObject *obj) {
//        for (AMapPOI *model in (NSArray *)obj) {
//            NSLog(@"========%@",model.location);
//        
//        }
//    };
//    
//      return searchView;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
////    BMapFooterView *searchView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BMapFooterView"];
//    return _myMapView;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 单选打勾
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 将地图中心移到选中的位置
    self.mySearchBar .showsCancelButton = NO;
    self.selectedPoi = _searchPoiArray[indexPath.row];
    [self setSelectedLocationWithLocation:_searchPoiArray[indexPath.row]];
    [_searchPoiArray removeAllObjects];
    [self.tableView reloadData];

}

-(void)locateAction{
    if (_myMapView.userTrackingMode != MAUserTrackingModeFollow) {
        [_myMapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    }
    [self actionLocation];
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
//        self.currentLocationCoordinate = mapView.userLocation.coordinate;
        NSLog(@"MAUserTrackingMode change %f == %f",mapView.userLocation.coordinate.latitude,mapView.userLocation.coordinate.longitude);
        
    }
    
}
- (void)setSelectedLocationWithLocation:(AMapPOI *)poi
{
    [self.myMapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude,poi.location.longitude) animated:YES];
    NSLog(@"选中位置%@",poi.location);
}

- (void)determineSendLocation
{
    
    
    
    
}
////6.设置选中的行所执行的动作
//-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //NSLog(@"%s",__FUNCTION__);
//    //NSUInteger row = [indexPath row];
//    return indexPath;
//    
//}
//
////设置让UITableView行缩进
//-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"%s",__FUNCTION__);
//    NSUInteger row = [indexPath row];
//    return row;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
