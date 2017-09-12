#import <UIKit/UIKit.h>

@class CCCurrencyCarouselViewController;

@protocol CCCurrencyCarouselViewControllerDelegate <NSObject>

- (void)currencyCarousel:(CCCurrencyCarouselViewController *)carousel
       didSelectCurrency:(NSString *)currency;

@end

@interface CCCurrencyCarouselViewController : UIViewController

@property(nonatomic, weak) id <CCCurrencyCarouselViewControllerDelegate> delegate;

- (instancetype)initWithCurrencies:(NSArray<NSString *> *)currencies;

@property(nonatomic, strong) NSArray<NSString *> *currencies;

- (void)selectCurrency:(NSString *)currency;

@end
