//
//  KGStatusBar.m
//
//  Created by Kevin Gibbon on 2/27/13.
//  Copyright 2013 Kevin Gibbon. All rights reserved.
//  @kevingibbon
//

#import "KGStatusBar.h"

@interface KGStatusBar ()
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong) UILabel *stringLabel;
@end

@implementation KGStatusBar

@synthesize topBar, overlayWindow, stringLabel;

+ (KGStatusBar*)sharedView {
    static dispatch_once_t once;
    static KGStatusBar *sharedView;
    dispatch_once(&once, ^ { sharedView = [[KGStatusBar alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (void)showSuccessWithStatus:(NSString*)status
{
    [KGStatusBar showWithStatus:status];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.5];
}

+ (void)showSuccessWithAttributedStatus:(NSAttributedString *)status
{
    [[KGStatusBar sharedView] showWithAttributedStatus:status];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.5];
}

+ (void)showWithStatus:(NSString*)status {
    [[KGStatusBar sharedView] showWithStatus:status];
}

+ (void)showErrorWithStatus:(NSString*)status {
    [[KGStatusBar sharedView] showWithStatus:status];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.5];
}

+ (void)dismiss {
    [[KGStatusBar sharedView] dismiss];
}

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)showWithStatus:(NSString *)status{
    [[KGStatusBar sharedView] showWithAttributedStatus:[[NSAttributedString alloc] initWithString:status]];
}

- (void)showWithAttributedStatus:(NSAttributedString *)status {
    
    if(!self.superview)
        [self.overlayWindow addSubview:self];
    [self.overlayWindow setHidden:NO];
    [self.topBar setHidden:NO];
    self.topBar.backgroundColor = self.topBarColor;
    
    CGRect frame = CGRectMake(0, 0, self.topBar.frame.size.width, self.topBar.frame.size.height);
    self.stringLabel.frame = CGRectInset(frame, 10, 0);
    self.stringLabel.alpha = 0.0;
    self.stringLabel.hidden = NO;
    self.stringLabel.attributedText = status;
    self.stringLabel.textColor = self.textColor;
    [UIView animateWithDuration:0.4 animations:^{
        self.stringLabel.alpha = 1.0;
    }];
    [self setNeedsDisplay];
}

- (void) dismiss
{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect topBarFrame = self.topBar.frame;
        topBarFrame.origin.y = -20;
        self.topBar.frame = topBarFrame;
    } completion:^(BOOL finished) {
        [topBar removeFromSuperview];
        topBar = nil;
        
        [overlayWindow removeFromSuperview];
        overlayWindow = nil;
    }];
}

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
        overlayWindow.windowLevel = UIWindowLevelStatusBar;
        
        // Transform depending on interafce orientation
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self rotation]);
        self.overlayWindow.transform = rotationTransform;
        self.overlayWindow.bounds = CGRectMake(0.f, 0.f, [self rotatedSize].width, [self rotatedSize].height);
        
        // Register for orientation changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRoration:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return overlayWindow;
}

- (UIView *)topBar {
    if(!topBar) {
        topBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20, [self rotatedSize].width, 20.0f)];
        [overlayWindow addSubview:topBar];
        [UIView animateWithDuration:0.4 animations:^{
            CGRect topBarFrame = topBar.frame;
            topBarFrame.origin.y = 0;
            topBar.frame = topBarFrame;
        }];
    }
    return topBar;
}

- (UILabel *)stringLabel {
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = self.textColor;
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        stringLabel.textAlignment = UITextAlignmentCenter;
#else
        stringLabel.textAlignment = NSTextAlignmentCenter;
#endif
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = self.textFont;
        stringLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    if(!stringLabel.superview)
        [self.topBar addSubview:stringLabel];
    
    return stringLabel;
}

#pragma mark - Handle Rotation

- (CGFloat)rotation
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat rotation = 0.f;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft: { rotation = -M_PI_2; } break;
        case UIInterfaceOrientationLandscapeRight: { rotation = M_PI_2; } break;
        case UIInterfaceOrientationPortraitUpsideDown: { rotation = M_PI; } break;
        case UIInterfaceOrientationPortrait: { } break;
        default: break;
    }
    return rotation;
}

- (CGSize)rotatedSize
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize rotatedSize = screenSize;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft: { rotatedSize = CGSizeMake(screenSize.height, screenSize.width); } break;
        case UIInterfaceOrientationLandscapeRight: { rotatedSize = CGSizeMake(screenSize.height, screenSize.width); } break;
        case UIInterfaceOrientationPortraitUpsideDown: { } break;
        case UIInterfaceOrientationPortrait: { } break;
        default: break;
    }
    return rotatedSize;
}

- (void)handleRoration:(id)sender
{
    // Based on http://stackoverflow.com/questions/8774495/view-on-top-of-everything-uiwindow-subview-vs-uiviewcontroller-subview
    
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self rotation]);
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration]
                     animations:^{
                         self.overlayWindow.transform = rotationTransform;
                         // Transform invalidates the frame, so use bounds/center
                         self.overlayWindow.bounds = CGRectMake(0.f, 0.f, [self rotatedSize].width, [self rotatedSize].height);
                         self.topBar.frame = CGRectMake(0.f, 0.f, [self rotatedSize].width, 20.f);
                     }];
}

@end
