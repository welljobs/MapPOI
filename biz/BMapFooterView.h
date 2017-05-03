//
//  BMapFooterView.h
//  biz
//
//  Created by mac on 2017/4/23.
//  Copyright © 2017年 1ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface BMapFooterView : UITableViewHeaderFooterView
+ (void)setSelectedLocationWithLocation:(AMapPOI *)poi;
@end
