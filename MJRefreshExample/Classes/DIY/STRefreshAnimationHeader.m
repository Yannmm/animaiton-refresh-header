//
//  STRefreshAnimationHeader.m
//  MJRefreshExample
//
//  Created by yannmm on 19/4/17.
//  Copyright © 2019 小码哥. All rights reserved.
//

#import "STRefreshAnimationHeader.h"
#import <CoreText/CoreText.h>

#define DURATION 5.0
#define TEXT @"starteos"

@interface STRefreshAnimationHeader ()

/// animation layer
@property (nonatomic, strong) CAShapeLayer *animationLayer;
/// <#属性说明#>
@property (nonatomic, assign) CFTimeInterval lastTimeOffset;
/// <#属性说明#>
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation STRefreshAnimationHeader

#pragma mark - Static

+ (UIBezierPath *)animationPath {
    static UIBezierPath *kAnimationPath = nil;
    
    if (kAnimationPath) return kAnimationPath;
    
    // Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 72.0f, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:TEXT
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    kAnimationPath = [UIBezierPath bezierPath];
    [kAnimationPath moveToPoint:CGPointZero];
    [kAnimationPath appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CGPathRelease(letters);
    CFRelease(font);
    
    return kAnimationPath;
}

+ (CGRect)animationBounds {
    static CGRect kPathBounds = {{ 0.0f, 0.0f }, { 0.0f, 0.0f }};
    if (CGRectEqualToRect(kPathBounds, CGRectZero)) {
        kPathBounds = CGPathGetBoundingBox([STRefreshAnimationHeader animationPath].CGPath);
    }
    return kPathBounds;
}

- (void) startAnimation
{
//    [self.animationLayer removeAllAnimations];

    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = DURATION;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = HUGE_VALF;
    [self.animationLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

#pragma mark - MJRefreshHeader

- (void)prepare
{
    [super prepare];
    
    self.backgroundColor = [UIColor magentaColor];
    
    CGRect rect = [STRefreshAnimationHeader animationBounds];
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - rect.size.width) / 2.0;
    CGFloat y = ((h + 10.0) - rect.size.height) / 2.0;
    self.animationLayer.frame = CGRectMake(x, y, w, h);
    
    self.mj_h = h + 10.0;
    
    [self.layer addSublayer:self.animationLayer];
    
    
    
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
    self.isLoading = pullingPercent > 0.0;
    
    if (self.state > MJRefreshStateIdle) return;
    // FIXME: for state from idle -> pulling, transition is OK;
    //        while from pulling -> idle is not correct
    self.animationLayer.timeOffset = pullingPercent;
//    if (pullingPercent > 0.0) { // 开始
//        self.animationLayer.timeOffset = self.lastTimeOffset + (pullingPercent - 1.0);
//    } else { // 结束
////        self.animationLayer.timeOffset = 0.0;
//    }
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        CFTimeInterval pausedTime = [self.animationLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        self.animationLayer.speed = 0.0;
        self.animationLayer.timeOffset = pausedTime;
        self.lastTimeOffset = pausedTime;
    } else if (state == MJRefreshStatePulling) {
        
        CFTimeInterval pausedTime = self.animationLayer.timeOffset;
        self.animationLayer.speed = 1.0;
        self.animationLayer.timeOffset = 0.0;
        self.animationLayer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self.animationLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.animationLayer.beginTime = timeSincePause;
        
    } else if (state == MJRefreshStateRefreshing) {
//        self.lastTimeOffset = 0.0;
    }
}

#pragma mark - Lazy

- (CAShapeLayer *)animationLayer {
    if (!_animationLayer) {
        UIBezierPath *path = [STRefreshAnimationHeader animationPath];
        _animationLayer = [CAShapeLayer layer];
        _animationLayer.bounds = [STRefreshAnimationHeader animationBounds];
        _animationLayer.geometryFlipped = YES;
        _animationLayer.path = path.CGPath;
        _animationLayer.strokeColor = [[UIColor blackColor] CGColor];
        _animationLayer.fillColor = nil;
        _animationLayer.lineWidth = 3.0f;
        _animationLayer.lineJoin = kCALineJoinBevel;
        
        _animationLayer.speed = 0.0;
        _animationLayer.hidden = YES;
    }
    return _animationLayer;
}

- (void)setLastTimeOffset:(CFTimeInterval)lastTimeOffset {
    _lastTimeOffset = lastTimeOffset;
}

- (void)setIsLoading:(BOOL)isLoading {
    BOOL old = _isLoading;
    if (old == isLoading) return;
    _isLoading = isLoading;
    if (_isLoading) {
        self.animationLayer.hidden = NO;
        [self startAnimation];
    } else {
        [self.animationLayer removeAllAnimations];
        self.animationLayer.hidden = YES;
    }
}

@end
