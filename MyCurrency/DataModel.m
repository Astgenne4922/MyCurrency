#import "DataModel.h"

@interface DataModel()

@end

@implementation DataModel

NSString *const API_BASEURL = @"https://api.exchangerate.host/";

#pragma mark - getInstance

+ (id)getInstance {
    static DataModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - getLastWeekFrom

- (NSArray *) getLastWeekFrom:(NSString *) from
                          toCurr:(NSString *) to {
    NSDate *today = [NSDate date];
    NSDate *lastWeek = [
        [NSCalendar currentCalendar]
        dateByAddingUnit:NSCalendarUnitDay
        value:-6
        toDate:[NSDate date]
        options:0
    ];
    
    NSDateComponents *todayComponents = [
        [NSCalendar currentCalendar]
        components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
        fromDate:today
    ];
    NSDateComponents *lastWeekComponents = [
        [NSCalendar currentCalendar]
        components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
        fromDate:lastWeek
    ];
    
    NSString *url = [
        NSString
        stringWithFormat: @"%@/timeseries?start_date=%04d-%02d-%02d&end_date=%04d-%02d-%02d&base=%@&symbols=%@",
        API_BASEURL,
        (int)lastWeekComponents.year,
        (int)lastWeekComponents.month,
        (int)lastWeekComponents.day,
        (int)todayComponents.year,
        (int)todayComponents.month,
        (int)todayComponents.day,
        from,
        to
    ];
    
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url]];
    NSError *err;
    NSDictionary *json = [
        NSJSONSerialization
        JSONObjectWithData:data
        options:NSJSONReadingMutableContainers
        error:&err
    ];
    
    NSMutableArray *table = [[NSMutableArray alloc] init];
    for (int i = 0; i < 7; ++i) {
        NSDate *day = [
            [NSCalendar currentCalendar]
            dateByAddingUnit:NSCalendarUnitDay
            value:-i
            toDate:[NSDate date]
            options:0
        ];
        NSDateComponents *components = [
            [NSCalendar currentCalendar]
            components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
            fromDate:day
        ];
        NSString *tmp = [
            NSString
            stringWithFormat: @"%04d-%02d-%02d: %@ -> %@ = %f",
            (int)components.year,
            (int)components.month,
            (int)components.day,
            from,
            to,
            [
                [
                    json
                    valueForKeyPath:[
                        NSString
                        stringWithFormat: @"rates.%04d-%02d-%02d.%@",
                        (int)components.year,
                        (int)components.month,
                        (int)components.day,
                        to
                    ]
                ]
                floatValue
            ]
        ];
        [table addObject:tmp];
    }
    
    return table;
}

#pragma mark - convert

- (float) convert:(float) amount
         fromCurr:(NSString *) from
           toCurr:(NSString *) to {
    
    NSString *url = [
        NSString
        stringWithFormat: @"%@/convert?from=%@&to=%@&amount=%f",
        API_BASEURL,
        from,
        to,
        amount
    ];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url]];
    NSError *err;
    NSDictionary *json = [
        NSJSONSerialization
        JSONObjectWithData:data
        options:NSJSONReadingMutableContainers
        error:&err
    ];
    
    return [[json valueForKeyPath:@"result"] floatValue];
}

#pragma mark - getSymbols

- (NSArray *) getSymbols {
    NSString *url = [NSString stringWithFormat: @"%@/symbols", API_BASEURL];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url]];
    NSError *err;
    NSDictionary *json = [
        NSJSONSerialization
        JSONObjectWithData:data
        options:NSJSONReadingMutableContainers
        error:&err
    ];
    
    NSArray *tmp = [[json valueForKeyPath:@"symbols"] allKeys];
    tmp = [tmp sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        if([self isFavorite:a] && ![self isFavorite:b]) return NSOrderedAscending;
        if(![self isFavorite:a] && [self isFavorite:b]) return NSOrderedDescending;
        
        return [a compare:b];
    }];
    
    return tmp;
}

#pragma mark - isFavorite

- (BOOL) isFavorite:(NSString *) currency {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    if ([preferences objectForKey:currency] == nil) {
        return NO;
    }
    else {
        return [preferences boolForKey:currency];
    }
}

#pragma mark - toggleFavorite

- (void) toggleFavorite:(NSString *) currency {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    [preferences setBool:![self isFavorite:currency] forKey:currency];
    
    [preferences synchronize];
}

@end
