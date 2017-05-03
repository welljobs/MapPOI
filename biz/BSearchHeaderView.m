//
//  BSearchHeaderView.m
//  biz
//
//  Created by mac on 2017/4/23.
//  Copyright © 2017年 1ge. All rights reserved.
//

#import "BSearchHeaderView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "UIColor+Helper.h"
#import "Masonry.h"

@interface BSearchHeaderView ()<AMapSearchDelegate,UISearchBarDelegate>
{
    // Poi搜索结果数组
    NSMutableArray *_searchPoiArray;
}

@property (nonatomic, strong) UITextView *myTextView;
@property (nonatomic,strong) AMapSearchAPI *searchAPI;


@end

@implementation BSearchHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor hexStringToColor:@"F1EEEF"];
//        self.mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
//        self.mySearchBar.placeholder = @"eeee";
//        self.mySearchBar.delegate = self;
//        [self.mySearchBar sizeToFit];
//        
//        UIView *searchTextField = nil;
//        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
//            self.mySearchBar.barTintColor = [UIColor hexStringToColor:@"27dcfb"];
//            searchTextField = [self.mySearchBar valueForKey:@"_searchField"];
//        }else{
//            for (UIView *subView in self.mySearchBar.subviews) {
//                if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
//                    searchTextField = subView;
//                    break;
//                }
//            }
//        }
//        if (searchTextField) {
////            searchTextField.backgroundColor = [UIColor hexStringToColor:@"27dcfb"];
////            searchTextField.layer.masksToBounds = YES;
////            searchTextField.layer.cornerRadius = 3.0f;
////            searchTextField.layer.borderColor = [UIColor whiteColor].CGColor;
////            searchTextField.layer.borderWidth = 0.5;
//            ((UITextField *)searchTextField).leftView.hidden = NO;
//            ((UITextField *)searchTextField).leftViewMode = UITextFieldViewModeAlways;
////            ((UITextField *)searchTextField).textColor = [UIColor whiteColor];
////            [((UITextField *)searchTextField) setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//        }
////        [self.mySearchBar setImage:[UIImage imageNamed:@"search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
//        [self.mySearchBar setImage:[UIImage imageNamed:@"cuo"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
//        UIImage* searchBarBg = [self GetImageWithColor:[UIColor hexStringToColor:@"F1EEEF"] andHeight:32.0f];
//        [self.mySearchBar  setBackgroundImage:searchBarBg];
//        [self.contentView addSubview:self.mySearchBar];
        
        _searchPoiArray = [NSMutableArray array];
        self.searchAPI = [[AMapSearchAPI alloc] init];
        self.searchAPI.delegate = self;
        
        self.myTextView = [[UITextView alloc] init];
        [self.contentView addSubview:self.myTextView];
        
//        [self.mySearchBar mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(0);
//            make.left.mas_equalTo(0);
//            make.right.mas_equalTo(0);
//            make.height.mas_equalTo(44);
//        }];
        
        [self.myTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
        }];
    }
    return self;
}
+ (instancetype)cellForTableView:(UITableView *)tableView{
    NSString *cellKey = NSStringFromClass([self class]);
    BSearchHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if (!cell) {
        cell = [[BSearchHeaderView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellKey];
    }
    return cell;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (void)setSearchViewBackgroundColor:(UIColor *)color{
    self.contentView.backgroundColor = color;
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
     if (response.pois.count == 0) {

    }
    else {
        [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
            [_searchPoiArray addObject:obj];
           
        }];
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
    self.isBeginSearch = YES;
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
    [self searchUserWithStr:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked: %@", searchBar.text);
    [searchBar resignFirstResponder];

    [self searchUserWithStr:searchBar.text];
    
    if (self.searchBlock) {
        self.searchBlock(_searchPoiArray);
    }
}

- (void)searchUserWithStr:(NSString *)string{
    NSString *strippedStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _searchAPI.delegate = self;
    [self searchPoiBySearchString:strippedStr];
}
- (void)searchPioDataBlock:(SearchPIOBlock)block{
    if (block) {
        block(self.searchBlock);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
