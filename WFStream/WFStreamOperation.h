//
//  WFStreamOperation.h
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WFStreamOperationType) {
    WFMapper,
    WFAction,
    WFPredicate,
};

@interface WFStreamOperation : NSObject{
    @package
    id (^_mapper)(id e);
    void (^_action)(id e);
    BOOL (^_predicate)(id e);
    WFStreamOperationType _type;
}
+(instancetype)operationWithMapper:(id (^)(id))mapper;
+(instancetype)operationWithAction:(void (^)(id))action;
+(instancetype)operationWithPredicate:(BOOL (^)(id))predicate;
@end

NS_ASSUME_NONNULL_END
