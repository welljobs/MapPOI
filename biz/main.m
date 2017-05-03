//
//  main.m
//  biz
//
//  Created by mac on 2017/4/23.
//  Copyright © 2017年 1ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        int val = 10;
        const char *fmt = "val=%d\n";
        void (^blk)(void) = ^{
            printf(fmt,val);
        };
        val = 2;
        fmt = "再一次输出val=%d\n";
        blk();
        val=5;
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
