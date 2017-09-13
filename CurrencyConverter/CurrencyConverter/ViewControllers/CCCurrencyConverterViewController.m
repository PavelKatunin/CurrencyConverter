#import "CCCurrencyConverterViewController.h"
#import "CCRatesLoader.h"
#import "CCCurrencyConverter.h"
#import "CCFloatingBackgroundView.h"
#import "CCJSONRatesParser.h"
#import "CCCurrencyCarouselViewController.h"
#import "CCRemoteDataLoader.h"
#import "CCCurrencyConverterViewController+Layout.h"

static const NSInteger kBackgroundBubblesCount = 5;
static const NSInteger kMaxAmountLength = 10;
static NSString *const kRatesURL = @"https://api.fixer.io/latest";

static NSDictionary *AttributesForAmountField() {
    return @{NSForegroundColorAttributeName : [UIColor whiteColor],
             NSFontAttributeName : [UIFont systemFontOfSize:40.f]};
}

static NSDictionary *AttributesForRatesField() {
    return @{NSForegroundColorAttributeName : [UIColor colorWithWhite:7.f alpha:0.8],
             NSFontAttributeName : [UIFont systemFontOfSize:20.f]};
}

@interface CCCurrencyConverterViewController () <UITextFieldDelegate, CCCurrencyCarouselViewControllerDelegate>

// Controllers
@property(nonatomic, weak) CCCurrencyCarouselViewController *fromCurrencyCarousel;
@property(nonatomic, weak) CCCurrencyCarouselViewController *toCurrencyCarousel;

// Models
@property(strong) CCRatesLoader *ratesLoader;
@property(strong) CCCurrencyConverter *converter;
@property(copy) NSString *currentFromCurrency;
@property(copy) NSString *currentToCurrency;

@end

@implementation CCCurrencyConverterViewController

#pragma mark - Initalization

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        CCJSONRatesParser *ratesParser = [[CCJSONRatesParser alloc] init];
        CCRemoteDataLoader *remoteDataLoader = [[CCRemoteDataLoader alloc] initWithURLString:kRatesURL];
        
        self.ratesLoader = [[CCRatesLoader alloc] initWithDataLoader:remoteDataLoader
                                                              parser:ratesParser];
        self.converter = [[CCCurrencyConverter alloc] initWithCurrencyRatesMap:[self localRatesMap]];
        
        [self updateRates];
        
        self.currentFromCurrency = self.converter.currencies[0];
        self.currentToCurrency = self.converter.currencies[0];
    }
    
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    [self.fromCurrencyCarousel selectCurrency:self.currentFromCurrency];
    [self.fromCurrencyCarousel selectCurrency:self.currentToCurrency];
    
    [self.view addConstraints:[self createConstraintsForBackgroundView]];
    
    [self.view addConstraints:[self createConstraintsForConverterViews]];
    
    [self.inputAmountTextField becomeFirstResponder];
}

#pragma mark - Private methods

- (void)invertCurrencies:(id)sender {
    NSString *fromCurrency = self.currentFromCurrency;
    NSString *toCurrency = self.currentToCurrency;
    
    [self.fromCurrencyCarousel selectCurrency:toCurrency];
    [self.toCurrencyCarousel selectCurrency:fromCurrency];
}

- (NSDictionary *)localRatesMap {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                       pathForResource:@"InitialRatesMap"
                                                       ofType:@"plist"]];
}

- (CCCurrencyCarouselViewController *)createCurrencyCarouselViewController {
    
    CCCurrencyCarouselViewController *carousel = [[CCCurrencyCarouselViewController alloc]
                                                  initWithCurrencies:self.converter.currencies];
    carousel.view.translatesAutoresizingMaskIntoConstraints = NO;
    carousel.delegate = self;
    
    return carousel;
}

- (void)updateRates {
    
    __weak CCCurrencyConverterViewController *wSelf = self;
    
    [self.ratesLoader loadRatesSuccess:^(NSDictionary *ratesMap) {
        
        wSelf.converter.currencyRatesMap = ratesMap;
        self.fromCurrencyCarousel.currencies = wSelf.converter.currencies;
        self.toCurrencyCarousel.currencies = wSelf.converter.currencies;
        [self updateAmountAndRateForAmount:self.inputAmountTextField.text.doubleValue];
        
    } fail:^(NSError *error) {
        // TODO: handle
    } targetQueue:dispatch_get_main_queue()];
}

- (void)updateAmountAndRateForAmount:(double)amount {
    double resultAmount = [self.converter convertAmount:amount
                                           fromCurrency:self.currentFromCurrency
                                             toCurrency:self.currentToCurrency];
    
    if (resultAmount == 0) {
        self.resultAmountLabel.text = @"";
    }
    else {
        self.resultAmountLabel.attributedText =
            [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.02f", resultAmount]
                                            attributes:AttributesForAmountField()];
    }
    
    
    double rateBetweenCurrencies = [self.converter rateBetweenCurrency:self.currentFromCurrency
                                                           andCurrency:self.currentToCurrency];
    self.rateBetweenCurrenciesLabel.attributedText =
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.02f %@ in 1 %@",
                                                    rateBetweenCurrencies,
                                                    self.currentToCurrency.uppercaseString,
                                                    self.currentFromCurrency.uppercaseString]
                                        attributes:AttributesForRatesField()];
}

- (void)setupSubviews {
    [self setupBackgroundView];
    [self setupHighlightView];
    [self setupInputAmountTextField];
    [self setupFromCarousel];
    [self setupInvertButton];
    [self setupToCarousel];
    [self setupResultAmountLabel];
    [self setupRateBetweenCurrenciesLabel];
}

- (void)setupBackgroundView {
    CCFloatingBackgroundView *backgroundView =
        [[CCFloatingBackgroundView alloc] initWithBubblesCount:kBackgroundBubblesCount];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backgroundView];
    self.backgroundView = backgroundView;
}

- (void)setupHighlightView {
    UIView *highlightView = [[UIView alloc] init];
    highlightView.translatesAutoresizingMaskIntoConstraints = NO;
    highlightView.backgroundColor = [UIColor blackColor];
    highlightView.alpha = 0.2;
    [self.view addSubview:highlightView];
    self.currentCurrenciesHighlightView = highlightView;
}

- (void)setupInputAmountTextField {
    UITextField *inputAmountTextField = [[UITextField alloc] init];
    inputAmountTextField.translatesAutoresizingMaskIntoConstraints = NO;
    inputAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
    inputAmountTextField.defaultTextAttributes = AttributesForAmountField();
    inputAmountTextField.textAlignment = NSTextAlignmentCenter;
    inputAmountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputAmountTextField.delegate = self;
    [self.view addSubview:inputAmountTextField];
    self.inputAmountTextField = inputAmountTextField;
}

- (void)setupFromCarousel {
    CCCurrencyCarouselViewController *fromCarousel = [self createCurrencyCarouselViewController];
    self.fromCurrencyCarousel = fromCarousel;
    [self addChildViewController:fromCarousel];
    [self.view addSubview:fromCarousel.view];
    self.fromCurrencyCarouselView = fromCarousel.view;
    [fromCarousel didMoveToParentViewController:self];
}

- (void)setupInvertButton {
    UIButton *invertButton = [[UIButton alloc] init];
    UIImage *image = [[UIImage imageNamed:@"invert"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [invertButton setImage:image forState:UIControlStateNormal];
    invertButton.tintColor = [UIColor whiteColor];
    invertButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:invertButton];
    [invertButton addTarget:self
                     action:@selector(invertCurrencies:)
           forControlEvents:UIControlEventTouchUpInside];
    self.invertCurrenciesButton = invertButton;
}

- (void)setupToCarousel {
    CCCurrencyCarouselViewController *toCarousel = [self createCurrencyCarouselViewController];
    self.toCurrencyCarousel = toCarousel;
    [self addChildViewController:toCarousel];
    [self.view addSubview:toCarousel.view];
    self.toCurrencyCarouselView = toCarousel.view;
    [toCarousel didMoveToParentViewController:self];
}

- (void)setupResultAmountLabel {
    UILabel *resultAmountLabel = [[UILabel alloc] init];
    resultAmountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    resultAmountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:resultAmountLabel];
    self.resultAmountLabel = resultAmountLabel;
}

- (void)setupRateBetweenCurrenciesLabel {
    UILabel *rateBetweenCurrenciesLabel = [[UILabel alloc] init];
    rateBetweenCurrenciesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    rateBetweenCurrenciesLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:rateBetweenCurrenciesLabel];
    self.rateBetweenCurrenciesLabel = rateBetweenCurrenciesLabel;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    
    NSMutableString *newAmountString = [textField.text mutableCopy];
    [newAmountString replaceCharactersInRange:range withString:string];
    
    [self updateAmountAndRateForAmount:newAmountString.doubleValue];
    
    return textField.text.length + string.length < kMaxAmountLength;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self updateAmountAndRateForAmount:0];
    
    return YES;
}

#pragma mark - CCCurrencyCarouselViewControllerDelegate

- (void)currencyCarousel:(CCCurrencyCarouselViewController *)carousel
       didSelectCurrency:(NSString *)currency {
    if (carousel == self.fromCurrencyCarousel) {
        self.currentFromCurrency = currency;
    }
    else if (carousel == self.toCurrencyCarousel) {
        self.currentToCurrency = currency;
    }
    
    [self updateAmountAndRateForAmount:[self.inputAmountTextField.text doubleValue]];
}

@end
