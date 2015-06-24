//
//  ViewController.m
//  4096
//
//  Created by tangmingming on 15-6-13.
//  Copyright (c) 2015年 tangmingming. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
//记录线程个数
@property (atomic,assign)int threadCount;
//options视图
@property (atomic,strong)UIView *opView;

@property (atomic,assign)int maxNum;

@end




@implementation ViewController

#pragma mark -视图加载
-(void)viewDidLoad{
    [super viewDidLoad];
    //创建游戏选项
    [self createGameOptions];
    //为地图创建手势
    [self createSwipeGesture];
    //创建地图
    [self createMapBlockMap];
    //创建方块
    [self createBlockWithState:1];
    [self.view addSubview:_mapView];
    [self loadSave];
}

#pragma mark -加载存档记录
-(void)loadSave{
    //获取文档路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //获取文件路径
    NSString *path =[NSString  stringWithFormat:@"%@/%@",paths[0], @"save.rtf"];
    //创建文件管理对象
    NSFileManager *nfm  = [NSFileManager defaultManager];
    //读取文件
    NSData *data1=  [nfm contentsAtPath:path];
    NSString *str=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    _maxNum=str.intValue;
    _lableMaxCount.text=[NSString stringWithFormat:@"最高纪录：%i",_maxNum];
    [_lableMaxCount setFont:[UIFont fontWithName:@"Marker Felt" size:15]];
    
}

#pragma mark -存档
-(void)setSave{
    int numCount=_lableCount.text.intValue;
    if (numCount>_maxNum) {
        //获取文档路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //获取文件路径
        NSString *path =[NSString  stringWithFormat:@"%@/%@",paths[0], @"save.rtf"];
        //创建文件管理对象
        NSFileManager *nfm  = [NSFileManager defaultManager];
        NSData *data = [[NSData alloc] init];//也可以通过简单方式赋值。
        data = [[NSString stringWithFormat:@"%i",numCount] dataUsingEncoding:NSUTF8StringEncoding];//把内容与data联系起来，并且规定好编码格式为utf8
        //写入文件
       [nfm createFileAtPath:path contents:data attributes:nil];
    }
}

#pragma mark 创建map格子
-(void)createMapBlockMap{
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            //创建map上面的方块格子
            UIView *mapblock=[[UIView alloc]initWithFrame:CGRectMake(70*i+4*(i+1), 70*j+4*(j+1), 70, 70)];
            [mapblock.layer setBackgroundColor:[BlockColor colorForLevel:0].CGColor];
            [mapblock.layer setCornerRadius:3.0];
            [_mapView addSubview:mapblock];
        }
    }
    
    
}

#pragma mark -生成方块
-(void)createBlockWithState:(int)state{
    NSArray *blockarray=_mapView.subviews;
    //游戏第一次开始时创建所有的方块
    if (state==1) {
        int value1 = arc4random() % 16+1;
        int value2 = arc4random() % 16+1;
        while (value1==value2) {
            value2= arc4random() % 16+1;
        }
        for (int i=0; i<blockarray.count; i++) {
            UIView *view1=(UIView *)blockarray[i];
            UIButton *btn =[[UIButton alloc]initWithFrame:view1.frame];
            btn.layer.zPosition=10;
            [btn.layer setCornerRadius:3.0];
            [btn setTag:i+1];
            [btn.titleLabel setFont:[UIFont fontWithName:@"Marker Felt" size:15]];
            if (i==value1||i==value2) {
                [btn setTitle:[NSString stringWithFormat:@"%i",2] forState:0];
                [btn setTitleColor:[BlockColor textColorForLevel:2] forState:0];
                [btn setBackgroundColor:[BlockColor colorForLevel:2]];
            }else{
                [btn setBackgroundColor:[BlockColor colorForLevel:0]];
                [btn setTitleColor:[BlockColor colorForLevel:0] forState:0];
                [btn setTitle:[NSString stringWithFormat:@"0"] forState:0];
            }
            _blockArray=[_blockArray arrayByAddingObject:btn];
            [_mapView addSubview:btn];
            
        }
    }
    else if(state==2&&_threadCount==0)//在所以的后台动画线程结束后
    {
        BOOL fs=NO;
        BOOL fs1=NO;
        //循环判断是否还存在空白的方块
        for (int i=0; i<_blockArray.count; i++)
        {
            UIButton *btn=[self findButton:_blockArray WithTag:i+1];
            //如果两个方块的title相等的话[游戏没有结束]
            if ([btn.titleLabel.text isEqualToString:@"0"])
            {
                fs=YES;
                fs1=YES;
                break;
            }
        }
        //如果有找到为空的方块，随机生成一个新的方块，替换空的方块
        while (fs1)
        {
            //产生随机数
            int value = arc4random() % 16+1;
            for (int i=0; i<_blockArray.count; i++)
            {
                UIButton *btnz =(UIButton *)_blockArray[i];
                if ([btnz.titleLabel.text isEqualToString:@"0"]&&btnz.tag==value)
                {
                    //根据随机数找出对应的空白方块，将这个方块修改为初始2
                    [btnz setTitle:@"2" forState:0];
                    [btnz setBackgroundColor:[BlockColor colorForLevel:2]];
                    [btnz setTitleColor:[BlockColor textColorForLevel:2] forState:0];
                    fs1=NO;
                    break;
                    
                }
            }
            
        }
        //如果没有找到为空的方块，判断游戏是否结束
        if (!fs) {
            [self GameOver];
            
        }
    }
}

#pragma mark -创建选项面板
-(void)createGameOptions{
    //方块数组初始化
    _blockArray =[NSArray new];
    //创建地图view
    _mapView=[[UIView alloc]initWithFrame:CGRectMake(10, 200, 300, 300)];
    [_mapView.layer setBackgroundColor:[BlockColor backgroundColor].CGColor];
    [_mapView.layer setCornerRadius:3.0];
    
    
    //初始化记分牌
    [_lableCount setFont:[UIFont fontWithName:@"Marker Felt" size:15]];
    _lableCount.text=@"0";
    
    //设置title的样式
    [_lable_4096 setFont:[UIFont fontWithName:@"Marker Felt" size:35]];
    
    //记分牌view
    [_view1.layer setCornerRadius:10.0];
    [_view1 setBackgroundColor:[BlockColor colorForLevel:4]];
    [_view2.layer setCornerRadius:10.0];
    [_view2 setBackgroundColor:[BlockColor colorForLevel:4]];
    
    //创建重新开始游戏按钮
    [_btnReset setBackgroundColor:[BlockColor colorForLevel:8]];
    [_btnReset setTitleColor:[UIColor whiteColor] forState:0];
    [_btnReset setTitleColor:[UIColor yellowColor] forState:1];
    [_btnReset.layer setCornerRadius:10];
    [_btnReset.titleLabel setFont:[UIFont fontWithName:@"Marker Felt" size:15]];
    //绑定事件
    [_btnReset addTarget:self action:@selector(reGame) forControlEvents:UIControlEventTouchUpInside];
    
    

    //游戏结束view
    _opView=[[UIView alloc]initWithFrame:CGRectMake(10, -200, 300, 200)];
    [_opView setBackgroundColor:[BlockColor colorForLevel:2]];
    [_opView.layer setCornerRadius:10.0];
    [_opView.layer setZPosition:99];
    
    //游戏结束标题
    UILabel * lableGameOver=[[UILabel alloc]initWithFrame:CGRectMake(60, 20, 210, 60)];
    [lableGameOver setText:@"GAME OVER"];
    [lableGameOver setTextColor:[UIColor whiteColor]];
    [lableGameOver setFont:[UIFont fontWithName:@"Marker Felt" size:35]];
    [_opView addSubview:lableGameOver];
    
    //游戏结束view上面的重新开始游戏按钮
    UIButton *opBtn=[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 55)];
    [opBtn setTitle:@"重新开始" forState:0];
    [opBtn.titleLabel setFont:[UIFont fontWithName:@"Marker Felt" size:15]];
    [opBtn setTitleColor:[UIColor grayColor] forState:0];
    [opBtn.layer setCornerRadius:13];
    [opBtn setBackgroundColor:[UIColor whiteColor]];
    [opBtn addTarget:self action:@selector(reGame) forControlEvents:UIControlEventTouchDown];
    //[opBtn setAlpha:1.0];
    [_opView addSubview:opBtn];
    //将父视图从实践响应中移除
    _opView.userInteractionEnabled = YES;
    //设置游戏结束view为隐藏
    [self.view addSubview:_opView];
}

#pragma mark -游戏重新开始
-(void)reGame{
    //初始化所以的方块
    for (int i=0; i<_blockArray.count; i++) {
        UIButton *btn=(UIButton*)_blockArray[i];
        [btn setTitle:@"0" forState:0];
        [btn setTitleColor:[BlockColor colorForLevel:0] forState:0];
        [btn setBackgroundColor:[BlockColor colorForLevel:0]];
    }
    //随机两个新的方块
    [self createBlockWithState:2];
    [self createBlockWithState:2];
    
    //还原游戏结束view
    [UIView animateWithDuration:0.5 animations:^{
        [_opView setFrame:CGRectMake(10, -220, 300, 200)];
    }];
    
    [self loadSave];
    _lableCount.text=@"0";
    
    //为游戏重新开始按钮添加一个关键帧动画
    CABasicAnimation *basicAnime=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [basicAnime setFromValue:[NSNumber numberWithFloat:1.0]];
    [basicAnime setToValue:[NSNumber numberWithFloat:1.3]];
    [basicAnime setDuration:0.2];
    [basicAnime setRepeatCount:1];
    [basicAnime setAutoreverses:YES];
    [_btnReset.layer addAnimation:basicAnime forKey:@"btnresetAnime"];
}

#pragma mark -游戏结束
-(void)GameOver{
    //循环所有的方块，判断游戏是否结束
    BOOL gameIsRun=NO;
    //纵向判断
    for (int i=0; i<_blockArray.count; i++)
    {
        int tag=i+1;
        int tagNext=tag+1;
        //排除纵向最后一个
        if (tag%4!=0) {
            //找出相邻两个方块
            UIButton *btn1=[self findButton:_blockArray WithTag:tag];
            UIButton *btn2=[self findButton:_blockArray WithTag:tagNext];
            //如果两个方块的title相等的话[游戏没有结束]
            if ([btn1.titleLabel.text isEqualToString:btn2.titleLabel.text])
            {
                gameIsRun=YES;
                break;
            }
        }
    }
    //横向判断【如果纵向判断没有得到结果】
    if (!gameIsRun) {
        int tmmA=1;
        for (int i=0; i<4; i++)
        {
            for (int j=0; j<4; j++)
            {
                int tag=tmmA+(j*4);
                int tagNext=tmmA+((j+1)*4);
                //排除横向最后一个
                if(tag<13)
                {
                    UIButton *btn1=[self findButton:_blockArray WithTag:tag];
                    UIButton *btn2=[self findButton:_blockArray WithTag:tagNext];
                    //如果两个方块的title相等的话[游戏没有结束]
                    if ([btn1.titleLabel.text isEqualToString:btn2.titleLabel.text])
                    {
                        gameIsRun=YES;
                        break;
                    }
                    
                }
            }
            tmmA++;
        }
    }
    //Game Over  如果横向判断和纵向判断没有得到结果
    if (!gameIsRun) {
        //显示游戏结束的视图动画
        [self setSave];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            //保存纪录
            
            [_opView setFrame:CGRectMake(10, 40, 300, 200)];
        } completion:^(BOOL finished) {
            //为游戏结束面板添加一个缩放动画
            CABasicAnimation *basicAnima=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
            [basicAnima setFromValue:[NSNumber numberWithFloat:1.0]];
            [basicAnima setToValue:[NSNumber numberWithFloat:1.1]];
            [basicAnima setDuration:0.2];
            [basicAnima setRepeatCount:MAXFLOAT];
            [basicAnima setAutoreverses:YES];
            
            [_opView.layer addAnimation:basicAnima forKey:@"GameOverShowAnima"];
           
        }];
        
    }

}

#pragma mark -创建滑动手势
-(void)createSwipeGesture{
    //上滑手势
    UISwipeGestureRecognizer *swiperUp=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureUp)];
    swiperUp.direction=UISwipeGestureRecognizerDirectionUp;
    //下滑手势
    UISwipeGestureRecognizer *swiperDown=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureDown)];
    swiperDown.direction=UISwipeGestureRecognizerDirectionDown;
    //左滑手势
    UISwipeGestureRecognizer *swiperLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureLeft)];
    swiperLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    //右滑手势
    UISwipeGestureRecognizer *swiperRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureRight)];
    swiperRight.direction=UISwipeGestureRecognizerDirectionRight;
    //添加手势
    [_mapView addGestureRecognizer:swiperUp];
    [_mapView addGestureRecognizer:swiperDown];
    [_mapView addGestureRecognizer:swiperLeft];
    [_mapView addGestureRecognizer:swiperRight];
    
}

#pragma mark -上滑手势动作
-(void)swipeGestureUp{
    //如果游戏结束view是显示的
    if (!_opView.frame.origin.y<0) {
        return;
    }
    int tmmA=1;
    //上滑手势必须要使方块从地图的上面开始移动
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            UIButton *btnz =[self findButton:_blockArray WithTag: tmmA+(j*4)];
            //如果当前按钮是在最边上位置上
            if (btnz.tag%4==1)  continue;
            //移动隐式动画
            [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                //记录一个后台线程开始
                _threadCount++;
                //移动次数循环，一格一格的移动
                for (int num=0; num<3; num++)
                {
                    CGRect rtNext=CGRectMake(btnz.frame.origin.x,btnz.frame.origin.y-74, 70, 70);
                    UIButton *btnNextz=[self findButtonSubviews:_blockArray WithCGRect:rtNext];
                    NSString *btnzText=btnz.titleLabel.text;
                    NSString *btnzNextText=btnNextz.titleLabel.text;
                    //如果当前按钮和下一个按钮都是0的话
                    if([btnzText isEqual:@"0"]&&[btnzNextText isEqual:@"0"])
                    {
                        continue;
                    }
                    else if([btnzNextText isEqual:@"0"]&&![btnzText isEqual:@"0"])//如果移动的位置是一个为0的按钮的话
                    {
                        //交换两个方块的位置
                        [btnNextz setFrame:btnz.frame];
                        [btnz setFrame:rtNext];
                        NSInteger tagz=btnz.tag;
                        btnz.tag=btnNextz.tag;
                        btnNextz.tag=tagz;
                    }
                    else if([btnzNextText isEqualToString:btnzText])//当前方块和下一个方块相同时
                    {
                        //改变两个方块的frame，title，color
                        int sumtext=btnzNextText.intValue*2;
                        int count=_lableCount.text.intValue+sumtext;
                        _lableCount.text=[NSString stringWithFormat:@"%i",count];
                        [btnz setTitle:[NSString stringWithFormat:@"%i",sumtext] forState:0];
                        [btnz setTitleColor:[BlockColor textColorForLevel:sumtext] forState:0];
                        [btnz setBackgroundColor:[BlockColor colorForLevel:sumtext]];
                        
                        
                        [btnNextz setTitle:@"0" forState:0];
                        [btnNextz setBackgroundColor:[BlockColor colorForLevel:0]];
                        [btnNextz setTitleColor:[BlockColor colorForLevel:0] forState:0];
                        [btnNextz setFrame:btnz.frame];
                        
                        [btnz setFrame:rtNext];
                        NSInteger tagz=btnz.tag;
                        btnz.tag=btnNextz.tag;
                        btnNextz.tag=tagz;
                    }
                    
                }} completion:^(BOOL fs){
                    //记录一个后台线程动画结束
                    _threadCount--;
                    //方块移动结束后的缩放动画
                    [self transformSacle:btnz];
                }];
        }
        tmmA++;
    }
    //生成新的方块
    [self createBlockWithState:2];
}

#pragma mark -下滑手势动作
-(void)swipeGestureDown{
    if (!_opView.frame.origin.y<0) {
        return;
    }
    //下滑手势必须要使方块从下面开始移动
    int tmmA=16;
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            //如果这是一个UIButton
            UIButton *btnz =[self findButton:_blockArray WithTag: tmmA-(j*4)];
            //如果当前按钮是在最边上位置上
            if (btnz.tag%4==0)  continue;
            
            [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                //记录一个后台线程开始结束
                _threadCount++;
                //移动次数循环，一格一格的移动
                for (int num=0; num<3; num++)
                {
                    CGRect rtNext=CGRectMake(btnz.frame.origin.x,btnz.frame.origin.y+74, 70, 70);
                    //根据移动后的位置找出对应的方块
                    UIButton *btnNextz=[self findButtonSubviews:_blockArray WithCGRect:rtNext];
                    
                    NSString *btnzText=btnz.titleLabel.text;
                    NSString *btnzNextText=btnNextz.titleLabel.text;
                    //如果当前按钮和下一个按钮都是0的话
                    if([btnzText isEqual:@"0"]&&[btnzNextText isEqual:@"0"])
                    {
                        continue;
                    }
                    
                    else if([btnzNextText isEqual:@"0"]&&![btnzText isEqual:@"0"])//如果移动的位置是一个为0的按钮的话
                    {
                        [btnNextz setFrame:btnz.frame];
                        [btnz setFrame:rtNext];
                        NSInteger tagz=btnz.tag;
                        btnz.tag=btnNextz.tag;
                        btnNextz.tag=tagz;
                        [btnNextz setBackgroundColor:[BlockColor colorForLevel:0]];
                    }
                    else if([btnzNextText isEqualToString:btnzText])//当前按钮和下一个按钮相同时
                    {
                        //改变两个方块的frame，color，title
                        int sumtext=btnzNextText.intValue*2;
                        int count=_lableCount.text.intValue+sumtext;
                        _lableCount.text=[NSString stringWithFormat:@"%i",count];
                        [btnNextz setTitle:[NSString stringWithFormat:@"%i",sumtext] forState:0];
                        [btnNextz setTitleColor:[BlockColor textColorForLevel:sumtext] forState:0];
                        [btnNextz setBackgroundColor:[BlockColor colorForLevel:sumtext]];
                        
                        [btnz setTitle:@"0" forState:0];
                        [btnz setTitleColor:[BlockColor colorForLevel:0] forState:0];
                        [btnz setBackgroundColor:[BlockColor colorForLevel:0]];
                    }
                    
                }} completion:^(BOOL fs){
                    //记录一个后台线程动画结束
                    _threadCount--;
                    [self transformSacle:btnz];
                }];
        }
        tmmA--;
    }
    //生成新的方块
    [self createBlockWithState:2];
}

#pragma mark -左滑手势动作
-(void)swipeGestureLeft{
    if (!_opView.frame.origin.y<0) {
        return;
    }
    //左滑手势必须要使方块从左边开始移动
    for (int i=0; i<_blockArray.count; i++) {
        UIButton *btnz =[self findButton:_blockArray WithTag:i+1];
        //如果当前按钮是在最边上位置上
        
        if (btnz.tag<=4) continue;
        
        [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            //记录一个后台线程开始结束
            _threadCount++;
            //移动次数循环，一格一格的移动
            for (int num=0; num<3; num++)
            {
                CGRect rtNext=CGRectMake(btnz.frame.origin.x-74,btnz.frame.origin.y, 70, 70);
                
                UIButton *btnNextz=[self findButtonSubviews:_blockArray WithCGRect:rtNext];
                NSString *btnzText=btnz.titleLabel.text;
                NSString *btnzNextText=btnNextz.titleLabel.text;
                //如果当前按钮和下一个按钮都是0的话
                if([btnzText isEqual:@"0"]&&[btnzNextText isEqual:@"0"])
                {
                    continue;
                }
                else if([btnzNextText isEqual:@"0"]&&![btnzText isEqual:@"0"])//如果移动的位置是一个为0的按钮的话
                {
                    [btnNextz setFrame:btnz.frame];
                    [btnz setFrame:rtNext];
                    NSInteger tagz=btnz.tag;
                    btnz.tag=btnNextz.tag;
                    btnNextz.tag=tagz;
                }
                else if([btnzNextText isEqualToString:btnzText])//当前按钮和下一个按钮相同时
                {
                    //改变两个方块的frame，titie，color
                    int sumtext=btnzNextText.intValue*2;
                    int count=_lableCount.text.intValue+sumtext;
                    _lableCount.text=[NSString stringWithFormat:@"%i",count];
                    [btnNextz setTitle:[NSString stringWithFormat:@"%i",sumtext] forState:0];
                    [btnNextz setTitleColor:[BlockColor textColorForLevel:sumtext] forState:0];
                    [btnNextz setBackgroundColor:[BlockColor colorForLevel:sumtext]];
                    
                    
                    [btnz setTitle:@"0" forState:0];
                    [btnz setTitleColor:[BlockColor colorForLevel:0] forState:0];
                    [btnz setBackgroundColor:[BlockColor colorForLevel:0]];
                }
                
            }} completion:^(BOOL fs){
                //记录一个后台线程动画结束
                _threadCount--;
                [self transformSacle:btnz];
            }];
    }
    //生成新的方块
    [self createBlockWithState:2];
}

#pragma mark -右滑手势动作
-(void)swipeGestureRight{
    if (!_opView.frame.origin.y<0) {
        return;
    }
    //右滑手势必须要使方块从右开始移动
    for (int i=(int)_blockArray.count-1; i>=0; i--) {
        UIButton *btnz =[self findButton:_blockArray WithTag: i+1];
        //如果当前按钮是在最边上位置上
        
        if (btnz.tag>=13)continue;
        
        [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            //记录一个后台线程开始结束
            _threadCount++;
            //移动次数循环，一格一格的移动
            for (int num=0; num<3; num++)
            {
                CGRect rtNext;
                //如果是最上边位置上
                rtNext=CGRectMake(btnz.frame.origin.x+74,btnz.frame.origin.y, 70, 70);
                
                UIButton *btnNextz=[self findButtonSubviews:_blockArray WithCGRect:rtNext];
                NSString *btnzText=btnz.titleLabel.text;
                NSString *btnzNextText=btnNextz.titleLabel.text;
                //如果当前按钮和下一个按钮都是0的话
                if([btnzText isEqual:@"0"]&&[btnzNextText isEqual:@"0"])
                {
                    continue;
                }
                else if([btnzNextText isEqual:@"0"]&&![btnzText isEqual:@"0"])//如果移动的位置是一个为0的按钮的话
                {
                    [btnNextz setFrame:btnz.frame];
                    [btnz setFrame:rtNext];
                    NSInteger tagz=btnz.tag;
                    btnz.tag=btnNextz.tag;
                    btnNextz.tag=tagz;
                }
                else if([btnzNextText isEqualToString:btnzText])//当前按钮和下一个按钮相同时
                {
                    //改变两个方块的title，color，frame
                    int sumtext=btnzNextText.intValue*2;
                    int count=_lableCount.text.intValue+sumtext;
                    _lableCount.text=[NSString stringWithFormat:@"%i",count];
                    [btnNextz setTitle:[NSString stringWithFormat:@"%i",sumtext] forState:0];
                    [btnNextz setTitleColor:[BlockColor textColorForLevel:sumtext] forState:0];
                    [btnNextz setBackgroundColor:[BlockColor colorForLevel:sumtext]];
                    
                    [btnz setTitle:@"0" forState:0];
                    [btnz setTitleColor:[BlockColor colorForLevel:0] forState:0];
                    [btnz setBackgroundColor:[BlockColor colorForLevel:0]];
                }
                
            }} completion:^(BOOL fs){
                //记录一个后台线程动画结束
                _threadCount--;
                [self transformSacle:btnz];
            }];
    }
    //生成新的方块
    [self createBlockWithState:2];
}

#pragma mark -根位置找出移动位置上的方块
-(UIButton *)findButtonSubviews:(NSArray *)array WithCGRect:(CGRect)rect{
    UIButton *btnNextz;
    for (int i=0; i<array.count; i++) {
        if ([array[i] isKindOfClass:[UIButton class]]  ) {
            UIButton *btnz =(UIButton *)array[i];
            //如果这两个方块的frame相等
            if (CGRectIntersectsRect(btnz.frame,rect)) {
                btnNextz=btnz;
                break;
            }
        }
    }
    return btnNextz;
}

#pragma mark -根据按钮的Tag值找出对应的方块
-(UIButton *)findButton:(NSArray *)array WithTag:(int)tag{
    UIButton *btnNextz;
    for (int i=0; i<array.count; i++) {
        if ([array[i] isKindOfClass:[UIButton class]]  ) {
            UIButton *btnz =(UIButton *)array[i];
            //如果这个两个方块的tag值相等
            if (btnz.tag==tag) {
                btnNextz=btnz;
                break;
            }
        }
    }
    return btnNextz;
}

#pragma makr -sacle 动画
-(void)transformSacle:(UIButton *)btn{
    if (_threadCount!=0) {
        return;
    }
    CALayer *layer=btn.layer;
    //创建动画
    CABasicAnimation *baAnime=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [baAnime setFromValue:[NSNumber numberWithFloat:1.25]];//开始倍数
    [baAnime setToValue:[NSNumber numberWithFloat:1]];//变化倍数
    [baAnime setDuration:0.15];//动画时间
    [baAnime setRepeatCount:1];//次数
    [baAnime setAutoreverses:NO];//是否还原
    //透明动画
    CABasicAnimation *opacityAni=[CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacityAni setFromValue:[NSNumber numberWithFloat:0.5]];
    [opacityAni setToValue:[NSNumber numberWithFloat:1.0]];
    [opacityAni setAutoreverses:YES];
    [opacityAni setDuration:0.05];
    [opacityAni setRepeatCount:1];
    //添加动画
    if (![btn.titleLabel.text isEqualToString:@"0"]) {
        [layer addAnimation:baAnime forKey:@"movedBaAnime"];
    }
    [self createBlockWithState:2];
    //[layer addAnimation:opacityAni forKey:@"movedOpcityAni"];
}



@end
