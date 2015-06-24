//
//  ViewController.h
//  4096
//
//  Created by tangmingming on 15-6-13.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlockColor.h"

@interface ViewController : UIViewController
@property (nonatomic,strong)UIView * mapView;
@property (weak, nonatomic) IBOutlet UILabel *lableCount;
@property (weak, nonatomic) IBOutlet UILabel *lableMaxCount;
@property (strong,nonatomic)NSArray * blockArray;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UILabel *lable_4096;

@end

