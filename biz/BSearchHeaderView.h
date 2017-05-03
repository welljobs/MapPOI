//
//  BSearchHeaderView.h
//  biz
//
//  Created by mac on 2017/4/23.
//  Copyright © 2017年 1ge. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SearchPIOBlock)(NSObject *obj);

@interface BSearchHeaderView : UITableViewCell
- (void)setSearchViewBackgroundColor:(UIColor *)color;
@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic,copy) SearchPIOBlock searchBlock;
- (void)searchPioDataBlock:(SearchPIOBlock)block;
@property BOOL isBeginSearch;
+(instancetype)cellForTableView:(UITableView *)tableView;
@end
