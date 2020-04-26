//
//  WFStreamOperation.m
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import "WFStreamOperation.h"

@implementation WFStreamOperation
+ (instancetype)operationWithMapper:(id  _Nonnull (^)(id _Nonnull))mapper{
    WFStreamOperation *operation = [[WFStreamOperation alloc] init];
    operation->_mapper = mapper;
    operation->_type = WFMapper;
    return operation;
}
+ (instancetype)operationWithAction:(void (^)(id _Nonnull))action{
    WFStreamOperation *operation = [[WFStreamOperation alloc] init];
    operation->_action = action;
    operation->_type = WFAction;
    return operation;
}
+ (instancetype)operationWithPredicate:(BOOL (^)(id _Nonnull))predicate{
    WFStreamOperation *operation = [[WFStreamOperation alloc] init];
    operation->_predicate = predicate;
    operation->_type = WFPredicate;
    return operation;
}
@end
