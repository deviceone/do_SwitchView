//
//  do_SwitchView_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_SwitchView_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"

@interface myLayer : CALayer

@property(nonatomic, strong)UIColor *myShadowColor;
@property(nonatomic, strong)UIColor *myContentColor;
@property(nonatomic, assign)BOOL isOn;
@property(nonatomic, assign)CGFloat board;

@end


@implementation do_SwitchView_UIView
{
    myLayer *_colorLayer;
    myLayer *_moveLayer;
    myLayer *_changLayer;
    //边框宽度
    CGFloat _board;
    CGFloat W,H;
    //YES表示正常显示W>H
    BOOL isNormal;
    //是否是开启状态
    BOOL isOn;
    //边框颜色
    UIColor *_221Color;
    //开始，按下点坐标
    CGPoint beginPoint;
    //是否长时间按下。长时间按下pan和tap手势无效。需要还原组件
    BOOL isLongTouch;
}

#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    
    isOn = NO;
    isLongTouch = YES;
    self.backgroundColor = [UIColor clearColor];
    _221Color = [UIColor colorWithRed:221*1.0/255 green:221*1.0/255 blue:221*1.0/255 alpha:1];
    
    _colorLayer = [[myLayer alloc] init];
    _colorLayer.myContentColor = _221Color;
    _colorLayer.myShadowColor = _221Color;
    [self.layer addSublayer:_colorLayer];
    
    _changLayer = [[myLayer alloc] init];
    _changLayer.myShadowColor = [UIColor clearColor];
    [self.layer addSublayer:_changLayer];
    
    _moveLayer = [[myLayer alloc] init];
    _moveLayer.myShadowColor = _221Color;
    _moveLayer.myContentColor = [UIColor whiteColor];
    [self.layer addSublayer:_moveLayer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfViewTap:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selfViewPan:)];
    [self addGestureRecognizer:pan];
}
#pragma mark touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isLongTouch = YES;
    [super touchesBegan:touches withEvent:event];
    if(isOn)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _moveLayer.frame = CGRectMake(W-H*5/4, 0, H*5/4, H);
            [_moveLayer setNeedsDisplay];
        } completion:^(BOOL finished) {
            NSLog(@"点击变大");
        }];
    }
    else
    {
        [UIView animateWithDuration:0.6 animations:^{
            _moveLayer.frame = CGRectMake(0, 0, H*5/4, H);
            _changLayer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
            [_moveLayer setNeedsDisplay];
        } completion:^(BOOL finished) {
            NSLog(@"点击变大");
        }];
    }
}
//解决长按，手势失效后遗留问题。touchesCancelled无效。touchesEnded有效
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if(isLongTouch)
        [self reloadMoveLayer];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if(isLongTouch)
        [self reloadMoveLayer];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if(CGColorGetAlpha(backgroundColor.CGColor) <= 0)
        _changLayer.myContentColor = [self superview].backgroundColor;
    else
        _changLayer.myContentColor = backgroundColor;
}
#pragma mark - private methed
- (void)reloadMoveLayer
{
    if(isOn)
    {
        [UIView animateWithDuration:0.2 animations:^{
            _moveLayer.frame = CGRectMake(W-H, 0, H, H);
            _changLayer.transform = CATransform3DMakeScale(0, 0, 1);
            [self setAllLayerDisplay];
        } completion:^(BOOL finished) {
            _colorLayer.myContentColor = [UIColor greenColor];
            _colorLayer.myShadowColor = [UIColor greenColor];
            [self setAllLayerDisplay];
            NSLog(@"还原 终点");
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            _moveLayer.frame = CGRectMake(0, 0, H, H);
            _changLayer.transform = CATransform3DMakeScale(1, 1, 1);
            [self setAllLayerDisplay];
        } completion:^(BOOL finished) {
            _colorLayer.myContentColor = _221Color;
            _colorLayer.myShadowColor = _221Color;
            [self setAllLayerDisplay];
            NSLog(@"还原 原点");
        }];
    }
}

- (void)selfViewTap:(UITapGestureRecognizer *)tap
{
    isLongTouch = NO;
    NSLog(@"%s",__func__);
    if(isOn)
    {
        _colorLayer.myShadowColor = _221Color;
        [self setAllLayerDisplay];
        [UIView animateWithDuration:0.2 animations:^{
            _moveLayer.frame = CGRectMake(_moveLayer.frame.origin.x-(W-H)/5, 0, H*6/4, H);
            _changLayer.transform = CATransform3DMakeScale(0.3, 0.3, 1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                _moveLayer.frame = CGRectMake(0, 0, H*6/4, H);
                _changLayer.transform = CATransform3DMakeScale(0.8, 0.8, 1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    _moveLayer.frame = CGRectMake(0, 0, H, H);
                    _changLayer.transform = CATransform3DMakeScale(1, 1, 1);
                } completion:^(BOOL finished) {
                    NSLog(@"关闭完成");
                    _colorLayer.myContentColor = _221Color;
                    [self setAllLayerDisplay];
                }];
            }];
        }];
    }
    else
    {
        _colorLayer.myShadowColor = [UIColor greenColor];
        [self setAllLayerDisplay];
        [UIView animateWithDuration:0.2 animations:^{
            NSLog(@"%f",W-H);
            _moveLayer.frame = CGRectMake((W-H)/5, 0, H*6/4,H);
            _changLayer.transform = CATransform3DMakeScale(0.8, 0.8, 1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                _moveLayer.frame = CGRectMake(W, 0,H*6/4, H);
                _changLayer.transform = CATransform3DMakeScale(0.3, 0.3, 1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    _moveLayer.frame = CGRectMake(W-H, 0, H, H);
                    _changLayer.transform = CATransform3DMakeScale(0, 0, 1);
                } completion:^(BOOL finished) {
                    NSLog(@"开启完成");
                    _colorLayer.myContentColor = [UIColor greenColor];
                    [self setAllLayerDisplay];
                }];
            }];
        }];
    }
    isOn = !isOn;
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_model.EventCenter FireEvent:@"changed" :_invokeResult ];
}
- (void)selfViewPan:(UIPanGestureRecognizer *)pan
{
    isLongTouch = NO;
    //NSLog(@"%s",__func__);
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
            beginPoint = [pan translationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
            [self chang:[pan translationInView:self]];
            break;
        case UIGestureRecognizerStateEnded:
            [self reloadMoveLayer];
            break;
        case UIGestureRecognizerStateCancelled:
            [self reloadMoveLayer];
            break;
        default:
            [self reloadMoveLayer];
            break;
    }
}

- (void)chang:(CGPoint)newPoint
{
    if(isOn)
    {
        if(newPoint.x-beginPoint.x >= (W-H)*4/5)
        {
            [UIView animateWithDuration:0.2 animations:^{
                _moveLayer.frame = CGRectMake(W-H, 0, H, H);
                _changLayer.transform = CATransform3DMakeScale(0, 0, 1);
            } completion:^(BOOL finished) {
                _colorLayer.myContentColor = [UIColor greenColor];
                _colorLayer.myShadowColor = [UIColor greenColor];
                [self setAllLayerDisplay];
            }];
        }
        else if(beginPoint.x-newPoint.x >= (W-H)*4/5)
        {
            [UIView animateWithDuration:0.2 animations:^{
                _moveLayer.frame = CGRectMake(0, 0, H*5/4, H);
                _changLayer.transform = CATransform3DMakeScale(1, 1, 1);
            } completion:^(BOOL finished) {
                _colorLayer.myContentColor = _221Color;
                _colorLayer.myShadowColor = _221Color;
                [self setAllLayerDisplay];
                beginPoint = newPoint;
                isOn = !isOn;
                doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
                [_model.EventCenter FireEvent:@"changed" :_invokeResult ];
            }];
        }
        else
        {
            NSLog(@"不处理");
        }
    }
    else
    {
        if(beginPoint.x-newPoint.x >= (W-H)*4/5)
        {
            [UIView animateWithDuration:0.2 animations:^{
                _moveLayer.frame = CGRectMake(0, 0, H, H);
                _changLayer.transform = CATransform3DMakeScale(1, 1, 1);
            } completion:^(BOOL finished) {
                _colorLayer.myContentColor = _221Color;
                _colorLayer.myShadowColor = _221Color;
                [self setAllLayerDisplay];
            }];
        }
        else if(newPoint.x-beginPoint.x >= (W-H)*4/5)
        {
            [UIView animateWithDuration:0.2 animations:^{
                _moveLayer.frame = CGRectMake(W-H*5/4, 0, H*5/4, H);
                _changLayer.transform = CATransform3DMakeScale(0, 0, 1);
            } completion:^(BOOL finished) {
                _colorLayer.myContentColor = [UIColor greenColor];
                _colorLayer.myShadowColor = [UIColor greenColor];
                [self setAllLayerDisplay];
                beginPoint = newPoint;
                isOn = !isOn;
                doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
                [_model.EventCenter FireEvent:@"changed" :_invokeResult ];
            }];
        }
        else
        {
            NSLog(@"不处理");
        }
    }
}
- (void)setAllLayerDisplay
{
    [_changLayer setNeedsDisplay];
    [_moveLayer setNeedsDisplay];
    [_colorLayer setNeedsDisplay];
}

//销毁所有的全局对象
- (void) OnDispose
{
    _model = nil;
    //自定义的全局属性
    [_colorLayer removeFromSuperlayer];
    _colorLayer = nil;
    
    [_moveLayer removeFromSuperlayer];
    _moveLayer = nil;
    
    [_changLayer removeFromSuperlayer];
    _changLayer = nil;
}
//实现布局
- (void) OnRedraw
{
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
    //实现布局相关的修改
    if(self.frame.size.width > self.frame.size.height)
    {
        isNormal = YES;
        W = self.frame.size.width;
        H = self.frame.size.height;
    }
    else
    {
        isNormal = YES;
        W = self.frame.size.height;
        H = self.frame.size.width;
    }
    _board = W/30;
    _colorLayer.frame = CGRectMake(0, 0, W, H);
    _colorLayer.board = _board;
    _changLayer.frame = CGRectMake(0, 0, W, H);
    _changLayer.board = _board;
    _moveLayer.frame = CGRectMake(_board, _board, H-_board*2, H-_board*2);
    _moveLayer.board = _board;
    
    [self setAllLayerDisplay];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_checked:(NSString *)newValue
{
    //自己的代码实现
    if([newValue isEqualToString:@"true"] || [newValue isEqualToString:@"1"])
        isOn = NO;
    else
        isOn = YES;
    [self selfViewTap:nil];
}

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (doJsonNode *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (doJsonNode *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}
@end






//自定义layer，用于显示。
@implementation myLayer

- (void)drawInContext:(CGContextRef)context
{
    //设置曲线
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:self.bounds.size.height/2.0];
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextClip(context);
    //内容上色
    CGContextSetFillColorWithColor(context, self.myShadowColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    
    
    UIBezierPath *bezierPath1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.board, self.board, self.bounds.size.width-2*self.board, self.bounds.size.height-2*self.board) cornerRadius:self.bounds.size.height/2.0];
    CGContextAddPath(context, bezierPath1.CGPath);
    CGContextClip(context);
    //内容上色
    CGContextSetFillColorWithColor(context, self.myContentColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    
    //UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}
@end
