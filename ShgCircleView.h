//
//  ShgCircleView.h
//  UniTest
//
//  Created by shg on 2021/3/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShgCircleView : UIView

/// 圆环进度
@property (nonatomic,assign) CGFloat progress;

/// 圆环宽度
@property (nonatomic,assign) CGFloat width;

/// 圆环背景色
@property (nonatomic,strong) UIColor *circleBackGroundColor;

/// 内部lable字体大小
@property (nonatomic,strong) UIFont *font;

/// 内部labe文字颜色
@property (nonatomic,strong) UIColor *textColor;

/// 当 cutDownTime > 0 时，执行动画
@property (nonatomic,assign) NSInteger cutDownTime;

/// 圆环颜色
@property (nonatomic,strong) UIColor *circleColor;

/// 当执行动画时起作用,默认为 YES
@property (nonatomic,assign) BOOL clockwise;

/// 设置内部lable显示内容
/// @param text 需要显示的内容
- (void)setText:(NSString *)text;

/// 开始动画
/// @param start 开始时的回调
- (void)start:(void(^)(ShgCircleView *circleView))start;

/// 重置动画，动画重新开始执行
- (void)reset;

/// 圆环头视图
@property (nonatomic,strong) UIView *endView;

@end

NS_ASSUME_NONNULL_END
