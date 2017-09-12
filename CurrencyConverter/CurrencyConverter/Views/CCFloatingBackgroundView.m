#import "CCFloatingBackgroundView.h"

CGFloat RandAlpha() {
    return (CGFloat)(rand() % 100) / 300.;
}

NSArray *DefaultGradientColors() {
    return @[
             (id)[[UIColor colorWithRed:34.0/255.0
                                  green:211/255.0
                                   blue:198/255.0
                                  alpha:1.0] CGColor],
             (id)[[UIColor colorWithRed:145/255.0
                                  green:72.0/255.0
                                   blue:203/255.0
                                  alpha:1.0] CGColor],
             ];
}

static const CGFloat kMinimumBubbleRadius = 30;
static const CGFloat kMaximumBubbleRadius = 100;

// TODO: implement animations

@implementation CCFloatingBackgroundView

#pragma mark -Initialization

- (instancetype)initWithBubblesCount:(int)bubblesCount {
    
    self = [super init];
    if (self) {
        for (int bubbleIndex = 0; bubbleIndex < bubblesCount; bubbleIndex++) {
            [self addSubview:[self createBubble]];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    gradient.frame = self.bounds;
    gradient.colors = DefaultGradientColors();
    
    [self.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - Private methods

- (CGRect)randCGRect {
    CGFloat radiusRange = kMaximumBubbleRadius - kMinimumBubbleRadius;
    CGFloat width = rand() % (int)radiusRange + kMinimumBubbleRadius;
    
    return CGRectMake(rand() % (int)([UIScreen mainScreen].bounds.size.width),
                      rand() % (int)([UIScreen mainScreen].bounds.size.height),
                      width,
                      width);
}

- (UIView *)createBubble {
    CGRect bubbleRect = [self randCGRect];
    UIView *circleView = [[UIView alloc] initWithFrame:bubbleRect];
    circleView.alpha = RandAlpha();
    circleView.layer.cornerRadius = bubbleRect.size.width / 2;
    circleView.backgroundColor = [UIColor whiteColor];
    circleView.layer.shadowOpacity = .5;
    circleView.layer.shadowColor = [[UIColor whiteColor] CGColor];
    circleView.layer.shadowOffset = CGSizeMake(0,0);
    circleView.layer.shadowRadius = rand() % 10 + 5;
    return circleView;
}

@end
