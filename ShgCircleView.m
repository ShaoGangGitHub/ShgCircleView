//
//  ShgCircleView.m
//  UniTest
//
//  Created by shg on 2021/3/18.
//

#import "ShgCircleView.h"

@interface ShgCircleView ()

@property (nonatomic,strong) UILabel *timeLB;
@property (nonatomic,assign) CGFloat orgProgress;
@property (nonatomic,weak) NSTimer *timer;
@property (nonatomic,copy) NSString *timeLBtext;
@property (nonatomic,copy) void (^start)(ShgCircleView *view);
@property (nonatomic,strong) UIView *endPointView;
@property (nonatomic,strong) CAShapeLayer *progressLayer;;

@end

@implementation ShgCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        [self addSubview:self.timeLB];
        self.cutDownTime = 0;
        self.clockwise = YES;
        
    }
    return self;
}

- (UIView *)endPointView
{
    if (!_endPointView) {
        _endPointView = [[UIView alloc] init];
        _endPointView.hidden = true;
        [self addSubview:_endPointView];
    }
    return _endPointView;
}

- (void)addCircle
{
    CGRect rect = self.bounds;
    UIBezierPath *backgroundpath = [UIBezierPath bezierPath];
    [backgroundpath addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:(rect.size.width - self.width)/2 startAngle:-M_PI_2 endAngle:3 * M_PI/2 clockwise:YES];
    
    CAShapeLayer *backLayer = [CAShapeLayer layer];
    backLayer.frame = rect;
    backLayer.fillColor =  [[UIColor clearColor] CGColor];
    backLayer.strokeColor  = self.circleBackGroundColor.CGColor;
    backLayer.lineWidth = self.width;
    backLayer.path = [backgroundpath CGPath];
    backLayer.strokeEnd = 1;
    [self.layer addSublayer:backLayer];
    
    UIBezierPath *cirPath = [UIBezierPath bezierPath];
    [cirPath addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:(rect.size.width - self.width)/2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:self.cutDownTime > 0 ? self.clockwise : YES];
    
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.frame = rect;
    self.progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    self.progressLayer.strokeColor  = [self.circleColor CGColor];
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.lineWidth = self.width;
    self.progressLayer.path = [cirPath CGPath];
    self.progressLayer.strokeEnd = 0;
    [self.layer addSublayer:self.progressLayer];
    
}

- (void)setEndView:(UIView *)endView
{
    _endView = endView;
    _endView.frame = CGRectMake(0, 0, self.width, self.width);
    [self.endPointView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.endPointView addSubview:_endView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.timeLB.frame = CGRectMake(self.width, self.width, self.bounds.size.width - 2 * self.width, self.bounds.size.height - 2 * self.width);
    self.endPointView.frame = CGRectMake(0, 0, self.width,self.width);
    self.endPointView.layer.masksToBounds = true;
    self.endPointView.layer.cornerRadius = self.endPointView.bounds.size.width/2;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress < 0 ? 0 : (progress > 1.0 ? 1.0 : progress);
    self.orgProgress = _progress;
}

- (void)setOrgProgress:(CGFloat)orgProgress
{
    _orgProgress = orgProgress;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.progressLayer.strokeEnd = strongSelf->_orgProgress;
        [strongSelf updateEndPoint];
        [strongSelf.progressLayer removeAllAnimations];
    });
}

-(void)updateEndPoint
{
    //转成弧度
    CGFloat angle = M_PI * 2 * self.orgProgress;
    float radius = (self.bounds.size.width - self.width)/2.0;
    int index = (angle)/M_PI_2;//用户区分在第几象限内
    float needAngle = angle - index * M_PI_2;//用于计算正弦/余弦的角度
    float x = 0,y = 0;//用于保存_dotView的frame
    switch (index) {
        case 0:
            x = radius + sinf(needAngle)*radius;
            y = radius - cosf(needAngle)*radius;
            break;
        case 1:
            x = radius + cosf(needAngle)*radius;
            y = radius + sinf(needAngle)*radius;
            break;
        case 2:
            x = radius - sinf(needAngle)*radius;
            y = radius + cosf(needAngle)*radius;
            break;
        case 3:
            x = radius - cosf(needAngle)*radius;
            y = radius - sinf(needAngle)*radius;
            break;
            
        default:
            break;
    }
    
    //更新圆环的frame
    CGRect rect = self.endPointView.frame;
    rect.origin.x = x;
    rect.origin.y = y;
    self.endPointView.frame = rect;
    //移动到最前
    [self bringSubviewToFront:self.endPointView];
    self.endPointView.hidden = false;
    if (self.orgProgress == 0 || self.orgProgress == 1) {
        self.endPointView.hidden = true;
    }
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    self.timeLB.font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.timeLB.textColor = textColor;
}

- (void)setCutDownTime:(NSInteger)cutDownTime
{
    _cutDownTime = cutDownTime;
    [self removeTimer];
    if (_cutDownTime > 0) {
        if (self.start) {
            if (self.start) {
                self.start(self);
            }
        }
        self.orgProgress = 0;
        [self addTimer];
    }
}

- (void)addTimer
{
    __block CGFloat time = self.cutDownTime;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 repeats:YES block:^(NSTimer * _Nonnull timer) {
            time = time - 0.02;
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (time <= 0) {
                time = strongSelf.cutDownTime;
                if (strongSelf.start) {
                    strongSelf.start(strongSelf);
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.timeLB.text = strongSelf.timeLBtext ? strongSelf.timeLBtext : [NSString stringWithFormat:@"%ld",(long)time];
            });
            strongSelf.orgProgress += strongSelf.progress/(strongSelf.cutDownTime * 50);
            if (strongSelf.orgProgress > strongSelf.progress) {
                strongSelf.orgProgress = 0;
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:strongSelf.timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)removeTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)drawRect:(CGRect)rect
{
    [self addCircle];
}

- (void)setTimeLBtext:(NSString *)timeLBtext
{
    _timeLBtext = timeLBtext;
    self.timeLB.text = _timeLBtext;
}

- (void)setText:(NSString *)text
{
    self.timeLBtext = text;
}

- (void)setStart:(void (^)(ShgCircleView *))start
{
    _start = start;
    if (self.cutDownTime > 0) {
        if (self.start) {
            self.start(self);
        }
    }
}

- (void)start:(void (^)(ShgCircleView * _Nonnull))start
{
    self.start = start;
}

- (void)reset
{
    self.orgProgress = 0;
    [self removeTimer];
    [self addTimer];
}

- (UILabel *)timeLB
{
    if (!_timeLB) {
        _timeLB = [[UILabel alloc] init];
        _timeLB.textAlignment = NSTextAlignmentCenter;
        _timeLB.text = @"------";
    }
    return _timeLB;
}

- (void)dealloc
{
    [self removeTimer];
}

@end
