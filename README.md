# CurrencyConverter
Currency Converter iOS Application

![alt text](https://user-images.githubusercontent.com/1636737/30331427-75549dc8-97e0-11e7-92bd-d859954e5839.gif)

# About
Application allows you to convert one currency to another using updated rates.
Simple UI with 2 carousel views and responsive amount recalculating.

# Installation
You need cocoapods.  
run in CurrencyConverter folder:  
pod install
  
open XCode workspace file

# Unit testing
All services and models are covered with unit tests.
Check "Models folder" for services.  

See files:  
CurrencyConverterTests.m   
CCRatesParserTests.m   
CCDataLoaderTests.m   
CCCurrencyStringTests.m   
CCRatesLoaderTests.m  

for testing XCode -> Product -> Test . 

# 3rd parties
Used:
cocoapods
iCarousel https://github.com/nicklockwood/iCarousel

# To be done:  
1. Add EarlGrey and UI tests . 
2. Setup CI / CD pipeline to run Unit and UI tests on every push . 
3. Copy to clipboard by tapping on result amount . 
4. Addd visual recognition for sum images . 
