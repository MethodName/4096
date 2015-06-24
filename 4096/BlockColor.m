//
//  BlockColor.m
//  4096
//
//  Created by tangmingming on 15-6-14.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import "BlockColor.h"

//RGB颜色封装
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

//RGB颜色封装（透明）
#define HEX(c)[UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

@implementation BlockColor


#pragma mark  -根据等级获取方块颜色
+ (UIColor *)colorForLevel:(NSInteger)level
{
    switch (level) {
        case 0:
            return RGB(245, 245, 245);
        case 2:
            return RGB(237, 224, 200);
        case 4:
            return RGB(242, 177, 121);
        case 8:
            return RGB(245, 149, 99);
        case 16:
            return RGB(246, 124, 95);
        case 32:
            return RGB(246, 94, 59);
        case 64:
            return RGB(237, 207, 114);
        case 128:
            return RGB(237, 204, 97);
        case 256:
            return RGB(237, 200, 80);
        case 512:
            return RGB(237, 197, 63);
        case 1024:
            return RGB(237, 194, 46);
        case 2048:
            return RGB(173, 183, 119);
        case 4096:
            return RGB(170, 183, 102);
        case 8192:
            return RGB(164, 183, 79);
        case 16384:
        default:
            return RGB(161, 183, 63);
    }
}

+ (UIColor *)buttonColor
{
    return RGB(250, 248, 239);
}

#pragma mark -根据等级获取标题颜色
+ (UIColor *)textColorForLevel:(NSInteger)level
{
    switch (level) {
        case 2:
        case 4:
            return [UIColor grayColor];
        default:
            return [UIColor whiteColor];
    }
}


+ (UIColor *)backgroundColor
{
    return RGB(204, 192, 179);
}


@end
