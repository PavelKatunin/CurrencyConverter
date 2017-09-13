#import "CCCurrencyConverterViewController+Layout.h"
#import "NSLayoutConstraint+Helpers.h"

CGFloat const horizontalOffset = 20;

@implementation CCCurrencyConverterViewController (Layout)

#pragma mark - Layout

- (NSArray<NSLayoutConstraint *> *)createConstraintsForBackgroundView {
    return [NSLayoutConstraint constraintsForWrappedSubview:self.backgroundView
                                                 withInsets:UIEdgeInsetsZero];
}

- (NSArray<NSLayoutConstraint *> *)createConstraintsForConverterViews {
    NSMutableArray *resultConstraints = [[NSMutableArray alloc] init];
    
    NSArray *inputAmountHorizontalConstraints =
        [NSLayoutConstraint horizontalConstraintsForWrappedSubview:self.inputAmountTextField
                                                        withInsets:UIEdgeInsetsMake(0,
                                                                                    horizontalOffset,
                                                                                    0,
                                                                                    horizontalOffset)];
    
    [resultConstraints addObjectsFromArray:inputAmountHorizontalConstraints];
    
    id <UILayoutSupport> topLayout = self.topLayoutGuide;
    
    
    NSDictionary *views = @{ @"inputAmountTextField" : self.inputAmountTextField,
                             @"topLayout" :   topLayout,
                             @"resultAmountLabel" : self.resultAmountLabel,
                             @"fromCurrencyCarouselView" : self.fromCurrencyCarouselView,
                             @"invertCurrenciesButton" : self.invertCurrenciesButton,
                             @"toCurrencyCarouselView" : self.toCurrencyCarouselView,
                             @"rateBetweenCurrenciesLabel" : self.rateBetweenCurrenciesLabel
                             };
    
    NSArray *verticalConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayout]-"
                                                        "[inputAmountTextField]-20-"
                                                        "[fromCurrencyCarouselView(40)]-20-"
                                                        "[invertCurrenciesButton]-20-"
                                                        "[toCurrencyCarouselView(40)]-20-"
                                                        "[resultAmountLabel]-10-[rateBetweenCurrenciesLabel]"
                                                  views:views];
    [resultConstraints addObjectsFromArray:verticalConstraints];
    
    NSArray *resultAmountHorizontalConstraints =
    [NSLayoutConstraint horizontalConstraintsForWrappedSubview:self.resultAmountLabel
                                                    withInsets:UIEdgeInsetsZero];
    
    [resultConstraints addObjectsFromArray:resultAmountHorizontalConstraints];
    
    NSArray *fromCarouselHorizontalConstraints =
    [NSLayoutConstraint horizontalConstraintsForWrappedSubview:self.fromCurrencyCarouselView
                                                    withInsets:UIEdgeInsetsZero];
    
    [resultConstraints addObjectsFromArray:fromCarouselHorizontalConstraints];
    
    NSArray *toCarouselHorizontalConstraints =
    [NSLayoutConstraint horizontalConstraintsForWrappedSubview:self.toCurrencyCarouselView
                                                    withInsets:UIEdgeInsetsZero];
    
    [resultConstraints addObjectsFromArray:toCarouselHorizontalConstraints];
    
    NSLayoutConstraint *buttonHorizontalConstraint =
    [NSLayoutConstraint constraintWithItem:self.invertCurrenciesButton
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0];
    
    [resultConstraints addObject:buttonHorizontalConstraint];
    
    NSLayoutConstraint *highlightTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.currentCurrenciesHighlightView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.fromCurrencyCarouselView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:-10];
    
    NSLayoutConstraint *highlightBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.currentCurrenciesHighlightView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.toCurrencyCarouselView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:10];
    
    NSLayoutConstraint *highlightWidthConstraint =
    [NSLayoutConstraint constraintWithItem:self.currentCurrenciesHighlightView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeWidth
                                multiplier:0.33
                                  constant:0];
    
    NSLayoutConstraint *highlightCenterConstraint =
    [NSLayoutConstraint constraintWithItem:self.currentCurrenciesHighlightView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0];
    
    [resultConstraints addObjectsFromArray:@[highlightTopConstraint,
                                             highlightBottomConstraint,
                                             highlightWidthConstraint,
                                             highlightCenterConstraint]];
    
    [resultConstraints addObjectsFromArray:
        [NSLayoutConstraint horizontalConstraintsForWrappedSubview:self.rateBetweenCurrenciesLabel
                                                        withInsets:UIEdgeInsetsZero]];
    
    
    return resultConstraints;
}

@end
