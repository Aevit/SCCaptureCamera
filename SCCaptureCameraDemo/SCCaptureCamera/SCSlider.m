//
//  SCSlider.m
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-19.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import "SCSlider.h"

#define DARK_GREEN_COLOR        [UIColor colorWithRed:10/255.0f green:107/255.0f blue:42/255.0f alpha:1.f]    //深绿色
#define LIGHT_GREEN_COLOR       [UIColor colorWithRed:143/255.0f green:191/255.0f blue:62/255.0f alpha:1.f]    //浅绿色



//#define SHOW_HALF_WHEN_CIRCLE_IS_TOP    1//是否让圆滑至两端后可以滑出线一半圆
//#define LINE_WIDTH                      1//线的宽度
//#define CIRCLE_RADIUS                   10//圆的半径
//#define GAP                             (SHOW_HALF_WHEN_CIRCLE_IS_TOP ? CIRCLE_RADIUS : 0)
//#define INVERSE_GAP                     (SHOW_HALF_WHEN_CIRCLE_IS_TOP ? 0 : CIRCLE_RADIUS)

@interface SCSlider () {
    CGFloat gap;
    CGFloat inverseGap;
}

@property (nonatomic, assign) SCSliderDirection direction;//方向（横或竖）
@property (nonatomic, strong) UIColor *bgLineColor;//整条线的颜色
@property (nonatomic, strong) UIColor *slidedLineColor;//滑动过的线的颜色
@property (nonatomic, strong) UIColor *circleColor;//圆的颜色
@property (nonatomic, assign) CGFloat scaleNum;//滑动的比值


@end


@implementation SCSlider

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame direction:SCSliderDirectionHorizonal];
}


/**
 *  初始化，可设置方向（横或竖）
 *
 *  @param frame     frame
 *  @param direction 方向
 *
 *  @return SCSlider
 */
- (id)initWithFrame:(CGRect)frame direction:(SCSliderDirection)direction {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.minValue = 0;
        self.maxValue = 1;
//        _value = 0;
        self.isFullFillCircle = NO;
        self.direction = direction;
        self.bgLineColor = [UIColor whiteColor];// LIGHT_GREEN_COLOR;
        self.slidedLineColor = [UIColor whiteColor];//DARK_GREEN_COLOR;
        self.circleColor = [UIColor whiteColor];
        
        self.showHalfWhenCirlceIsTop = YES;
        self.lineWidth = 1;
        self.circleRadius = 10;
    }
    return self;
}

#pragma mark ----------public---------
/**
 *  drawRect，此函数将所有用到的参数都放在一起，方便查看。也可直接在外部类设置好某个值后，手动调用setNeedsDisplay函数
 *
 *  @param bgLineColor     整条线的颜色色
 *  @param slidedLineColor 滑过的部分的颜色
 *  @param circleColor     圆的颜色
 *  @param shouldShowHalf  是否让圆可以滑出一半
 *  @param lineWidth       线的宽度
 *  @param circleRadius    圆的半径
 */
- (void)fillLineColor:(UIColor*)bgLineColor
      slidedLineColor:(UIColor*)slidedLineColor
          circleColor:(UIColor*)circleColor
       shouldShowHalf:(BOOL)shouldShowHalf
            lineWidth:(CGFloat)lineWidth
         circleRadius:(CGFloat)circleRadius
     isFullFillCircle:(BOOL)isFullFillCircle {
    
    if (bgLineColor) {
        self.bgLineColor = bgLineColor;
    }
    if (slidedLineColor) {
        self.slidedLineColor = slidedLineColor;
    }
    if (circleColor) {
        self.circleColor = circleColor;
    }
    self.showHalfWhenCirlceIsTop = shouldShowHalf;
    self.lineWidth = lineWidth;
    self.circleRadius = circleRadius;
    self.isFullFillCircle = isFullFillCircle;
    [self setNeedsDisplay];
}

/**
 *  设置value值
 *
 *  @param value          value值
 */
- (void)setValue:(CGFloat)value {
    [self setValue:value shouldCallBack:YES];
}

/**
 *  设置value值，并设置是否要调用回调函数
 *
 *  @param value          value值
 *  @param shouldCallBack 是否调用回调函数
 */
- (void)setValue:(CGFloat)value shouldCallBack:(BOOL)shouldCallBack {
    if (value != _value) {
        if (value < _minValue) {
            _value = _minValue;
            return;
        } else if (value > _maxValue) {
            _value = _maxValue;
            return;
        }
        _value = value;
        
        if (!shouldCallBack) {
            _scaleNum = (_value - _minValue) / (_maxValue - _minValue);
        }
        
        [self setNeedsDisplay];
        
        if (shouldCallBack) {
            if (_didChangeValueBlock) {
                _didChangeValueBlock(value);
            } else if ([self.delegate respondsToSelector:@selector(didChangeValueSCSlider:value:)]) {
                [self.delegate didChangeValueSCSlider:self value:value];
            }
        }
    }
}

/**
 *  value改变后的回调
 *
 *  @param didChangeValueBlock value改变的回调block
 */
- (void)buildDidChangeValueBlock:(DidChangeValueBlock)didChangeValueBlock {
    if (_didChangeValueBlock != didChangeValueBlock) {
        self.didChangeValueBlock = didChangeValueBlock;
    }
}

/**
 *  滑动结束后的回调
 *
 *  @param touchEndBlock 滑动结束后的回调block
 */
- (void)buildTouchEndBlock:(TouchEndBlock)touchEndBlock {
    if (_touchEndBlock != touchEndBlock) {
        self.touchEndBlock = touchEndBlock;
    }
}

#pragma mark -----------drawRect--------------
- (void)drawRect:(CGRect)rect {
    gap = (_showHalfWhenCirlceIsTop ? _circleRadius : 0);
    inverseGap = (_showHalfWhenCirlceIsTop ? 0 : _circleRadius);
    
    //生成画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //画总体的线
    CGContextSetStrokeColorWithColor(context, _bgLineColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, _lineWidth);//线的宽度
    CGFloat startLineX = (_direction == SCSliderDirectionHorizonal ? gap : (self.frame.size.width - _lineWidth) / 2);
    CGFloat startLineY = (_direction == SCSliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : gap);
    
    CGFloat endLineX = (_direction == SCSliderDirectionHorizonal ? self.frame.size.width - gap : (self.frame.size.width - _lineWidth) / 2);
    CGFloat endLineY = (_direction == SCSliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : self.frame.size.height- gap);
    CGContextMoveToPoint(context, startLineX, startLineY);//起点
    CGContextAddLineToPoint(context, endLineX, endLineY);//终点
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    //画已滑动进度的线
    CGContextSetStrokeColorWithColor(context, _slidedLineColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, _lineWidth);//线的宽度
    CGFloat slidedLineX = (_direction == SCSliderDirectionHorizonal ? MAX(gap, (_scaleNum * self.frame.size.width - gap)) : startLineX);
    CGFloat slidedLineY = (_direction == SCSliderDirectionHorizonal ? startLineY : MAX(gap, (_scaleNum * self.frame.size.height - gap)));
    CGContextMoveToPoint(context, startLineX, startLineY);//起点
    CGContextAddLineToPoint(context, slidedLineX, slidedLineY);//终点
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    //外层圆
    CGFloat penWidth = 1.f;
    CGContextSetStrokeColorWithColor(context, _circleColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, penWidth);//线的宽度
    if (_isFullFillCircle) {
        CGContextSetFillColorWithColor(context, _circleColor.CGColor);//填充颜色
    } else {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);//填充颜色
    }
    CGContextSetShadow(context, CGSizeMake(1, 1), 1.f);//阴影
    CGFloat circleX = (_direction == SCSliderDirectionHorizonal ? MAX(_circleRadius + penWidth, slidedLineX - penWidth - inverseGap) : startLineX);
    CGFloat circleY = (_direction == SCSliderDirectionHorizonal ? startLineY : MAX(_circleRadius + penWidth, slidedLineY - penWidth - inverseGap));
    CGContextAddArc(context, circleX, circleY, _circleRadius, 0, 2 * M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    
    //内层圆
    if (!_isFullFillCircle) {
        CGContextSetStrokeColorWithColor(context, nil);//画笔颜色
        CGContextSetLineWidth(context, 0);//线的宽度
        CGContextSetFillColorWithColor(context, _circleColor.CGColor);//填充颜色
        CGContextSetShadow(context, CGSizeMake(0, 0), 0.f);//阴影
        CGContextAddArc(context, circleX, circleY, _circleRadius / 2, 0, 2 * M_PI, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    }
    
    //    UIBezierPath
}

#pragma mark ---------touch-----------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

#pragma mark ----------private---------
/**
 *  滑动结束，调用回调函数
 */
- (void)callbackTouchEnd:(BOOL)isTouchEnd {
    self.isSliding = !isTouchEnd;
    if (_touchEndBlock) {
        _touchEndBlock(_value, isTouchEnd);
    } else if ([self.delegate respondsToSelector:@selector(didSCSliderTouchEnd:value:isTouch:)]) {
        [self.delegate didSCSliderTouchEnd:self value:_value isTouch:isTouchEnd];
    }
}


/**
 *  根据滑动后的value更新
 *
 *  @param touches touch的NSSet
 */
- (void)updateTouchPoint:(NSSet*)touches {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.scaleNum = (_direction == SCSliderDirectionHorizonal ? touchPoint.x : touchPoint.y) / (_direction == SCSliderDirectionHorizonal ? self.frame.size.width : self.frame.size.height);
}

/**
 *  重写setMinValue，设置value的初始值
 *
 *  @param minValue 最小值
 */
- (void)setMinValue:(CGFloat)minValue {
    if (_minValue != minValue) {
        _minValue = minValue;
        _value = minValue;
    }
}


/**
 *  设置滑动的比值
 *
 *  @param scaleNum 滑动的比值
 */
- (void)setScaleNum:(CGFloat)scaleNum {
    if (_scaleNum != scaleNum) {
        _scaleNum = scaleNum;
        
        self.value = _minValue + scaleNum * (_maxValue - _minValue);
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
