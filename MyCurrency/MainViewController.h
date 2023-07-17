#ifndef MainViewController_h
#define MainViewController_h

#import <UIKit/UIKit.h>
#import "DataModel.h"

@class MainViewController;

@interface MainViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDataSource>

@end

#endif /* MainViewController_h */
