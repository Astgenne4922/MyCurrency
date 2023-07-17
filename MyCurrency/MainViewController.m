#import "MainViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *fromPicker;
@property (weak, nonatomic) IBOutlet UITextField *fromField;

@property (weak, nonatomic) IBOutlet UIPickerView *toPicker;
@property (weak, nonatomic) IBOutlet UITextField *toField;

@property (weak, nonatomic) IBOutlet UITableView *weekRateTable;

@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;

@property (strong, nonatomic) NSArray *symbols;
@property (retain,     nonatomic) DataModel *model;
@end

@implementation MainViewController {
    
}

#pragma mark - viewDidLoad

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.model = [DataModel getInstance];
    
    self.symbols = [self.model getSymbols];
    
    self.fromPicker.dataSource = self;
    self.fromPicker.delegate = self;

    self.fromField.delegate = self;
    [
        self.fromField
        addTarget:self
        action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged
    ];
    self.fromField.text = @"1";
    
    self.toPicker.dataSource = self;
    self.toPicker.delegate = self;
    
    self.toField.delegate = self;
    [
        self.toField
        addTarget:self
        action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged
    ];
    
    [
        self
        convert:self.fromField
        fromPicker:self.fromPicker
        toPicker:self.toPicker
        in:self.toField
    ];
    
    self.weekRateTable.dataSource = self;
    
    [self.fromButton setImage:[UIImage imageNamed:@"favoriteOn"] forState:UIControlStateSelected];
    [self.fromButton setImage:[UIImage imageNamed:@"favoriteOff"] forState:UIControlStateNormal];
    self.fromButton.selected = [
        self.model
        isFavorite:[
            self.symbols
            objectAtIndex:[
                self.fromPicker
                selectedRowInComponent:0
            ]
        ]
    ];
    
    [self.toButton setImage:[UIImage imageNamed:@"favoriteOn"] forState:UIControlStateSelected];
    [self.toButton setImage:[UIImage imageNamed:@"favoriteOff"] forState:UIControlStateNormal];
    self.toButton.selected = [
        self.model
        isFavorite:[
            self.symbols
            objectAtIndex:[
                self.toPicker
                selectedRowInComponent:0
            ]
        ]
    ];
}

#pragma mark - PickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
     return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component {
    return self.symbols.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
     return [self.symbols objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    if(thePickerView == self.fromPicker){
        [
            self
            convert:self.toField
            fromPicker:self.toPicker
            toPicker:self.fromPicker
            in:self.fromField
        ];
        self.fromButton.selected = [
            self.model
            isFavorite:[
                self.symbols
                objectAtIndex:[
                    self.fromPicker
                    selectedRowInComponent:0
                ]
            ]
        ];
    }
    if(thePickerView == self.toPicker){
        [
            self
            convert:self.fromField
            fromPicker:self.fromPicker
            toPicker:self.toPicker
            in:self.toField
        ];
        self.toButton.selected = [
            self.model
            isFavorite:[
                self.symbols
                objectAtIndex:[
                    self.toPicker
                    selectedRowInComponent:0
                ]
            ]
        ];
    }
    
    [self.weekRateTable reloadData];
}

#pragma mark - TextField methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(nonnull NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (newString.length == 0) {
        textField.text = @"0";
        return NO;
    }
    
    NSNumberFormatter* formatter= [[NSNumberFormatter alloc]init];
    formatter.numberStyle= NSNumberFormatterDecimalStyle;
    formatter.allowsFloats= YES;
    formatter.minimum= 0;
    formatter.maximumFractionDigits = 6;
    return [formatter numberFromString: newString] != nil;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([[textField.text substringFromIndex:textField.text.length - 1]  isEqual: @"."]) return;
    if(textField == self.fromField) {
        [
            self
            convert:self.fromField
            fromPicker:self.fromPicker
            toPicker:self.toPicker
            in:self.toField
        ];
    }
    if(textField == self.toField) {
        [
            self
            convert:self.toField
            fromPicker:self.toPicker
            toPicker:self.fromPicker
            in:self.fromField
        ];
    }
}

#pragma mark - convert

- (void)convert:(UITextField *) amount
     fromPicker:(UIPickerView *) from
       toPicker:(UIPickerView *) to
            in:(UITextField *) output {
    float a = [amount.text floatValue];
    NSString *f = [
        self.symbols
        objectAtIndex:[
            from
            selectedRowInComponent:0
        ]
    ];
    NSString *t = [
        self.symbols
        objectAtIndex:[
            to
            selectedRowInComponent:0
        ]
    ];
    output.text = [
        NSString stringWithFormat:@"%f",
        [
            self.model
            convert:a
            fromCurr:f
            toCurr:t
        ]
    ];
}

#pragma mark - TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [
        tableView
        dequeueReusableCellWithIdentifier:@"dayRate"
        forIndexPath:indexPath
    ];
    NSString *from = [
        self.symbols
        objectAtIndex:[
            self.fromPicker
            selectedRowInComponent:0
        ]
    ];
    NSString *to = [
        self.symbols
        objectAtIndex:[
            self.toPicker
            selectedRowInComponent:0
        ]
    ];
    cell.textLabel.text = [
        [
            self.model
            getLastWeekFrom:from
            toCurr:to
        ]
        objectAtIndex:indexPath.row
    ];
    return cell;
}

#pragma mark - Button listener

- (IBAction)toggleFavorite:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    NSString *from = [
        self.symbols
        objectAtIndex:[
            self.fromPicker
            selectedRowInComponent:0
        ]
    ];
    NSString *to = [
        self.symbols
        objectAtIndex:[
            self.toPicker
            selectedRowInComponent:0
        ]
    ];
    
    if(sender == self.fromButton) {
        [self.model toggleFavorite:from];
    }
    if(sender == self.toButton) {
        [self.model toggleFavorite:to];
    }
    
    self.symbols = [self.model getSymbols];
    
    [self.fromPicker reloadComponent:0];
    [self.toPicker reloadComponent:0];
    
    [
        self.fromPicker
        selectRow:[
            self.symbols
            indexOfObject:from
        ]
        inComponent:0
        animated:NO
    ];
    [
        self.toPicker
        selectRow:[
            self.symbols
            indexOfObject:to
        ]
        inComponent:0
        animated:NO
    ];
    
    self.fromButton.selected = [self.model isFavorite:from];
    self.toButton.selected = [self.model isFavorite:to];
}

@end
