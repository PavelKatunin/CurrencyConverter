#import <UIKit/UIKit.h>
#import "CCCurrencyCarouselViewController.h"

@interface CCCurrencyConverterViewController : UIViewController

// UI
@property(nonatomic, weak) UIView *backgroundView;
@property(nonatomic, weak) UIView *currentCurrenciesHighlightView;
@property(nonatomic, weak) UITextField *inputAmountTextField;
@property(nonatomic, weak) UIView *fromCurrencyCarouselView;
@property(nonatomic, weak) UIView *toCurrencyCarouselView;
@property(nonatomic, weak) UIButton *invertCurrenciesButton;
@property(nonatomic, weak) UILabel *resultAmountLabel;
@property(nonatomic, weak) UILabel *rateBetweenCurrenciesLabel;

@end

