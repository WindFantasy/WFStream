//
//  WFStreamImpl.h
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFStreamImpl : NSObject{
    @public
    BOOL _doA;
}
@property (nonatomic, assign) NSUInteger groups;
- (instancetype)initWithSource:(NSArray *)source;

- (void)peek:(void (^)(__unsafe_unretained id))action;
- (void)map:(id (^)(__unsafe_unretained id))mapper;
- (void)filter:(BOOL (^)(__unsafe_unretained id))predicate;

- (NSArray *)toArray;
- (NSOrderedSet *)toSet;
- (NSDictionary *)toDictionary:(NSString *)propertyName;
- (void)iterate;

- (WFStreamImpl *)add:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END

