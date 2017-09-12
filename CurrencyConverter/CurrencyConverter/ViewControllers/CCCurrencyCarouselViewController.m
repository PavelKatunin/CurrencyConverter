#import "CCCurrencyCarouselViewController.h"
#import <iCarousel.h>
#import "NSLayoutConstraint+Helpers.h"
#import "NSString+Currency.h"

static NSDictionary *AttributesForCurrencyLabel() {
    return @{NSForegroundColorAttributeName : [UIColor whiteColor],
             NSFontAttributeName : [UIFont systemFontOfSize:40.f]};
}

@interface CCCurrencyCarouselViewController () <iCarouselDataSource, iCarouselDelegate>

@property(nonatomic, weak) iCarousel *carousel;

@end

@implementation CCCurrencyCarouselViewController

#pragma mark - Properties

- (void)setCurrencies:(NSArray<NSString *> *)currencies {
    _currencies = currencies;
    [self.carousel reloadData];
}

#pragma mark - Initialization

- (instancetype)initWithCurrencies:(NSArray<NSString *> *)currencies {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        self.currencies = currencies;
    }
    
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    iCarousel *carousel = [self createCarouselView];
    self.carousel = carousel;
    [self.view addSubview:carousel];
    
    [self.view addConstraints:[self createConstraints]];
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.currencies.count;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSInteger)index
         reusingView:(nullable UIView *)view {
    
    NSString *currency = self.currencies[index];
    
    UILabel *resultView = [self labelForCurrency:currency];
    
    return resultView;
}

#pragma mark - iCarouselDelegate

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return [self carouselItemWidth];
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    [self.delegate currencyCarousel:self
                  didSelectCurrency:self.currencies[carousel.currentItemIndex]];
}

#pragma mark - Public methods

- (void)selectCurrency:(NSString *)currency {
    self.carousel.currentItemIndex = [self indexOfCurrency:currency];
}

- (NSInteger)indexOfCurrency:(NSString *)currency {
    return [self.currencies indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [[obj normalizedCurrency] isEqualToString:[currency normalizedCurrency]];
    }];
}

#pragma mark - Private methods

- (CGFloat)carouselItemWidth {
    return self.view.frame.size.width / 3;
}

- (CGFloat)carouselItemHeight {
    return 40;
}

- (UILabel *)labelForCurrency:(NSString *)currency {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               [self carouselItemWidth],
                                                               [self carouselItemHeight])];
    [self setCurrency:currency toLabel:label];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void)setCurrency:(NSString *)currency toLabel:(UILabel *)label {
    label.attributedText = [[NSAttributedString alloc] initWithString:currency.uppercaseString
                                                           attributes:AttributesForCurrencyLabel()];
}

- (iCarousel *)createCarouselView {
    iCarousel *carousel = [[iCarousel alloc] init];
    carousel.type = iCarouselTypeLinear;
    carousel.translatesAutoresizingMaskIntoConstraints = NO;
    carousel.dataSource = self;
    carousel.delegate = self;
    carousel.stopAtItemBoundary = YES;
    return carousel;
}

- (NSArray *)createConstraints {
    NSMutableArray *resultConstraints = [[NSMutableArray alloc] init];
    
    [resultConstraints addObjectsFromArray:[NSLayoutConstraint constraintsForWrappedSubview:self.carousel
                                                                                 withInsets:UIEdgeInsetsZero]];
    
    
    return resultConstraints;
}

@end
