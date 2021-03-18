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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.timeLB.frame = CGRectMake(self.width, self.width, self.bounds.size.width - 2 * self.width, self.bounds.size.height - 2 * self.width);
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress < 0 ? 0 : (progress > 1.0 ? 1.0 : progress);
    self.orgProgress = _progress;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    self.timeLB.font = font;
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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 repeats:YES block:^(NSTimer * _Nonnull timer) {
        time = time - 0.02;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (time <= 0) {
            time = strongSelf.cutDownTime;
            if (strongSelf.start) {
                strongSelf.start(strongSelf);
            }
        }
        strongSelf.timeLB.text = strongSelf.timeLBtext ? strongSelf.timeLBtext : [NSString stringWithFormat:@"%ld",(long)time];
        strongSelf.orgProgress += strongSelf.progress/(strongSelf.cutDownTime * 50);
        if (strongSelf.orgProgress > strongSelf.progress) {
            strongSelf.orgProgress = 0;
        }
        [strongSelf setNeedsDisplay];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
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
    UIBezierPath *backgroundpath = [UIBezierPath bezierPath];
    [backgroundpath addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:(rect.size.width - self.width)/2 startAngle:-M_PI_2 endAngle:3 * M_PI/2 clockwise:YES];
    backgroundpath.lineWidth = self.width;
    [self.circleBackGroundColor set];
    [backgroundpath stroke];
    
    UIBezierPath *cirPath = [UIBezierPath bezierPath];
    [cirPath addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:(rect.size.width - self.width)/2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI * self.orgProgress clockwise:self.cutDownTime > 0 ? self.clockwise : YES];
    cirPath.lineWidth = self.width;
    [self.circleColor set];
    cirPath.lineCapStyle = kCGLineCapRound;
    [cirPath stroke];
    
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
