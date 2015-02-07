//
//  SCSlider.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-19.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidChangeValueBlock)(CGFloat value);
typedef void(^TouchEndBlock)(CGFloat value, BOOL isTouchEnd);
@protocol SCSliderDelegate;

typedef enum {
    SCSliderDirectionHorizonal  =   0,
    SCSliderDirectionVertical   =   1
} SCSliderDirection;

@interface SCSlider : UIControl

@property (nonatomic, assign) CGFloat minValue;//最小值
@property (nonatomic, assign) CGFloat maxValue;//最大值
@property (nonatomic, assign) CGFloat value;//滑动值

@property (nonatomic, assign) BOOL showHalfWhenCirlceIsTop;     //是否让圆滑至两端后可以超出线半径个像素长
@property (nonatomic, assign) BOOL lineWidth;                   //线的宽度
@property (nonatomic, assign) BOOL circleRadius;                //圆的半径
@property (nonatomic, assign) BOOL isFullFillCircle;            //YES：中间全部填充颜色    NO：一个环

@property (nonatomic, assign) BOOL isSliding;                   //是否正在滑动


@property (nonatomic, copy) DidChangeValueBlock didChangeValueBlock;
@property (nonatomic, copy) TouchEndBlock touchEndBlock;
@property (nonatomic, assign) id <SCSliderDelegate> delegate;

/**
 *  初始化，可设置方向（横或竖）
 *
 *  @param frame     frame
 *  @param direction 方向
 *
 *  @return SCSlider
 */
- (id)initWithFrame:(CGRect)frame direction:(SCSliderDirection)direction;




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
     isFullFillCircle:(BOOL)isFullFillCircle;




/**
 *  value改变后的回调
 *
 *  @param didChangeValueBlock value改变的回调block
 */
- (void)buildDidChangeValueBlock:(DidChangeValueBlock)didChangeValueBlock;




/**
 *  滑动结束后的回调
 *
 *  @param touchEndBlock 滑动结束后的回调block
 */
- (void)buildTouchEndBlock:(TouchEndBlock)touchEndBlock;




/**
 *  设置value值，并设置是否要调用回调函数
 *
 *  @param value          value值
 *  @param shouldCallBack 是否调用回调函数
 */
- (void)setValue:(CGFloat)value shouldCallBack:(BOOL)shouldCallBack;

@end



@protocol SCSliderDelegate <NSObject>

@optional
- (void)didChangeValueSCSlider:(SCSlider*)slider value:(CGFloat)value;
- (void)didSCSliderTouchEnd:(SCSlider*)slider value:(CGFloat)value isTouch:(BOOL)isTouchEnd;

@end