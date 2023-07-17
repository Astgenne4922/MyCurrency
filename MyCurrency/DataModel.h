#ifndef DataModel_h
#define DataModel_h

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

+ (id) getInstance;
- (NSArray *) getLastWeekFrom:(NSString *) from toCurr:(NSString *) to;
- (float) convert:(float) amount fromCurr:(NSString *) from toCurr:(NSString *) to;
- (NSArray *) getSymbols;
- (BOOL) isFavorite:(NSString *) currency;
- (void) toggleFavorite:(NSString *) currency;

@end

#endif /* DataModel_h */
