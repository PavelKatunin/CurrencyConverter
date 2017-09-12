#import "CCCurrencyConverterViewController.h"
#import "CCRatesLoader.h"
#import "CCCurrencyConverter.h"
#import "CCFloatingBackgroundView.h"
#import "NSLayoutConstraint+Helpers.h"
#import "CCJSONRatesParser.h"
#import "CCCurrencyCarouselViewController.h"

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

// UI
@property(nonatomic, weak) UIView *backgroundView;
@property(nonatomic, weak) UIView *currentCurrenciesHighlightView;
@property(nonatomic, weak) UITextField *inputAmountTextField;
@property(nonatomic, weak) UIView *fromCurrencyCarouselView;
@property(nonatomic, weak) UIView *toCurrencyCarouselView;
@property(nonatomic, weak) UIButton *invertCurrenciesButton;
@property(nonatomic, weak) UILabel *resultAmountLabel;
@property(nonatomic, weak) UILabel *rateBetweenCurrenciesLabel;

// Controller
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
        self.ratesLoader = [[CCRatesLoader alloc] initWithUrlString:kRatesURL
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
                                                    self.currentToCurrency,
                                                    self.currentFromCurrency]
                                        attributes:AttributesForRatesField()];
}

- (void)setupSubviews {
    // background
    CCFloatingBackgroundView *backgroundView =
        [[CCFloatingBackgroundView alloc] initWithBubblesCount:kBackgroundBubblesCount];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backgroundView];
    self.backgroundView = backgroundView;
    
    // current currencies highlight view
    UIView *highlightView = [[UIView alloc] init];
    highlightView.translatesAutoresizingMaskIntoConstraints = NO;
    highlightView.backgroundColor = [UIColor blackColor];
    highlightView.alpha = 0.2;
    [self.view addSubview:highlightView];
    self.currentCurrenciesHighlightView = highlightView;
    
    // input text field
    UITextField *inputAmountTextField = [[UITextField alloc] init];
    inputAmountTextField.translatesAutoresizingMaskIntoConstraints = NO;
    inputAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
    inputAmountTextField.defaultTextAttributes = AttributesForAmountField();
    inputAmountTextField.textAlignment = NSTextAlignmentCenter;
    inputAmountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputAmountTextField.delegate = self;
    [self.view addSubview:inputAmountTextField];
    self.inputAmountTextField = inputAmountTextField;
    
    // from currency carousel
    CCCurrencyCarouselViewController *fromCarousel = [self createCurrencyCarouselViewController];
    self.fromCurrencyCarousel = fromCarousel;
    [self addChildViewController:fromCarousel];
    [self.view addSubview:fromCarousel.view];
    self.fromCurrencyCarouselView = fromCarousel.view;
    [fromCarousel didMoveToParentViewController:self];
    
    // invert button
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
    
    // to currency carousel
    CCCurrencyCarouselViewController *toCarousel = [self createCurrencyCarouselViewController];
    self.toCurrencyCarousel = toCarousel;
    [self addChildViewController:toCarousel];
    [self.view addSubview:toCarousel.view];
    self.toCurrencyCarouselView = toCarousel.view;
    [toCarousel didMoveToParentViewController:self];
    
    // result amount label
    UILabel *resultAmountLabel = [[UILabel alloc] init];
    resultAmountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    resultAmountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:resultAmountLabel];
    self.resultAmountLabel = resultAmountLabel;
    
    // rate between currencies label
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

#pragma mark - Layout

- (NSArray<NSLayoutConstraint *> *)createConstraintsForBackgroundView {
    return [NSLayoutConstraint constraintsForWrappedSubview:self.backgroundView
                                                 withInsets:UIEdgeInsetsZero];
}

- (NSArray<NSLayoutConstraint *> *)createConstraintsForConverterViews {
    NSMutableArray *resultConstraints = [[NSMutableArray alloc] init];
    
    NSArray *inputAmountHorizontalConstraints =
        [NSLayoutConstraint horizontalConstraintsForWrappedSubview:self.inputAmountTextField
                                                        withInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    
    [resultConstraints addObjectsFromArray:inputAmountHorizontalConstraints];
    
    id <UILayoutSupport> topLayout = self.topLayoutGuide;
    
    NSArray *verticalConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:
         @"V:[topLayout]-"
         "[_inputAmountTextField]-20-"
         "[_fromCurrencyCarouselView(40)]-20-"
         "[_invertCurrenciesButton]-20-"
         "[_toCurrencyCarouselView(40)]-20-"
         "[_resultAmountLabel]-10-[_rateBetweenCurrenciesLabel]"
                                                  views:NSDictionaryOfVariableBindings(_inputAmountTextField,
                                                                                       topLayout,
                                                                                       _resultAmountLabel,
                                                                                       _fromCurrencyCarouselView,
                                                                                       _invertCurrenciesButton,
                                                                                       _toCurrencyCarouselView,
                                                                                       _rateBetweenCurrenciesLabel)];
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
    
    [resultConstraints addObjectsFromArray:[NSLayoutConstraint horizontalConstraintsForWrappedSubview:self.rateBetweenCurrenciesLabel
                                                                                           withInsets:UIEdgeInsetsZero]];
    
    
    return resultConstraints;
}

@end
