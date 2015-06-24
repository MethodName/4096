//
//  TestUIViewController.m
//  4096
//
//  Created by tangmingming on 15-6-14.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import "TestUIViewController.h"

@implementation TestUIViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    int a=1;
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            NSLog(@"%i",a+(j*4));
        }
        a++;
        NSLog(@"_________________");
    }
    
}
@end
