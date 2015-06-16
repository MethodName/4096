//
//  BlockColor.h
//  4096
//
//  Created by tangmingming on 15-6-14.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BlockColor : NSObject

+ (UIColor *)colorForLevel:(NSInteger)level;

+ (UIColor *)buttonColor;

+ (UIColor *)textColorForLevel:(NSInteger)level;

+ (UIColor *)backgroundColor;
@end
