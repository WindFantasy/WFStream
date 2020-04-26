//
//  WFStreamImpl.m
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import "WFStreamImpl.h"
#import "WFStreamOperation.h"

@interface WFStreamImpl (Concurrent)
-(void)concurrent:(void (^)(id e))collector;
@end

@implementation WFStreamImpl{
    NSArray *_source;
    NSMutableArray *_operations;
}
- (instancetype)initWithSource:(NSArray *)source {
    self = [super init];
    if (self) {
        _source = source.copy;
        _operations = [NSMutableArray array];
        _groups = 1;
    }
    return self;
}
-(void)peek:(void (^)(id))action{
    WFStreamOperation *op = [WFStreamOperation operationWithAction:action];
    [_operations addObject:op];
}
-(void)map:(id  (^)(id))mapper{
    WFStreamOperation *op = [WFStreamOperation operationWithMapper:mapper];
    [_operations addObject:op];
}
-(void)filter:(BOOL (^)(id))predicate{
    WFStreamOperation *op = [WFStreamOperation operationWithPredicate:predicate];
    [_operations addObject:op];
}
- (NSArray *)toArray{
    NSMutableArray *array = [NSMutableArray array];
    [self collect:^(__unsafe_unretained id e) {
        [array addObject:e];
    }];
    return array;
}
- (NSOrderedSet *)toSet{
    NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
    [self collect:^(__unsafe_unretained id e) {
        [set addObject:e];
    }];
    return set;
}
- (NSDictionary *)toDictionary:(NSString *)propertyName{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self collect:^(__unsafe_unretained id e) {
        id k = [e valueForKey:propertyName];
        dictionary[k] = e;
    }];
    return dictionary;
}
- (void)iterate{
    [self collect:^(__unsafe_unretained id e) {
        
    }];
}
- (void)collect:(void (^)(__unsafe_unretained id e))collector{
    if (_groups == 1) {
        [self seriallyWithSource:_source collector:collector];
    } else {
        [self concurrent:collector];
    }
}
- (WFStreamImpl *)add:(NSArray *)array{
    NSMutableArray *source = [NSMutableArray arrayWithArray:_source];
    [source addObjectsFromArray:array];
    return [[WFStreamImpl alloc] initWithSource:source];
}

-(void)seriallyWithSource:(NSArray *)source collector:(void (^)(__unsafe_unretained id e))collector{
    NSInteger count = _operations.count;
    __unsafe_unretained WFStreamOperation *ops[count];
    for (NSInteger i = 0; i < count; i++) {
        ops[i] = _operations[i];
    }
    for (id e in source) {
        id a = e;
        for (int i = 0; i < count; i++) {
            WFStreamOperation *p = ops[i];
            switch (p->_type) {
                case WFMapper:
                    a =  p->_mapper(a);
                    break;
                case WFAction:
                    p->_action(a);
                    break;
                case WFPredicate:
                    if (!p->_predicate(a)) {
                        a = nil;
                    }
                    break;
                default:
                    NSAssert(NO, @"Unexpected operation type.");
            }
            if(!a){
                break;
            }
        }
        if (a) {
            collector(a);
        }
    }
}
@end

#define Trace(args ...)
//#define Trace(args ...) NSLog(args)

@implementation WFStreamImpl (Concurrent)
-(void)concurrent:(void (^)(id e))collector{
    NSInteger len = _source.count;
    len = len / _groups;
    NSInteger n = _groups - 1;
    
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    NSInteger offset = 0;
    for (NSInteger i = 0; i < n; i++, offset += len) {
        [self seriallyWithRange:NSMakeRange(offset, len) lock:lock condition:i collector:collector];
    }
    [self seriallyWithRange:NSMakeRange(offset, _source.count - offset) lock:lock condition:n collector:collector];
}
-(void)seriallyWithRange:(NSRange)range lock:(NSConditionLock *)lock condition:(NSInteger)status collector:(void (^)(id e))collector{
    NSArray *source = [_source subarrayWithRange:range];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if([lock tryLockWhenCondition:status]){
            Trace(@"[%ld] get lock.", range.location);
            [self seriallyWithSource:source collector:collector];
            Trace(@"[%ld] is done.", range.location);
            [lock unlockWithCondition:status + 1];
        } else {
            Trace(@"[%ld] is preparing.", range.location);
            NSMutableArray *array = [NSMutableArray array];
            [self seriallyWithSource:source collector:^(__unsafe_unretained id e) {
                [array addObject:e];
            }];
            Trace(@"[%ld] is waiting.", range.location);
            [lock lockWhenCondition:status];
            Trace(@"[%ld] is finishing up.", range.location);
            for (id e in array) {
                collector(e);
            }
            Trace(@"[%ld] is done.", range.location);
            [lock unlockWithCondition:status + 1];
        }
    });
}
@end
