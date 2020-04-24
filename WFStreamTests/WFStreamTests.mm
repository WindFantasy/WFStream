//
//  WFStreamTests.mm
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import <XCTest/XCTest.h>
#import "Employee.h"
#import <WFStream/WFStream.h>
#import "WFStreamImpl.h"

@interface WFStreamTests : XCTestCase
@end

#define SIZE 100000

@implementation WFStreamTests

- (void)setUp {
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
- (void)testLoop {
    NSArray<Employee *> *employees = [self create:SIZE];
    NSMutableArray *array = [NSMutableArray array];
    [self measureBlock:^{
        for (Employee *e in employees) {
            [e doWork];
            [array addObject:e];
        }
    }];
}
- (void)testStream {
    NSArray<Employee *> *employees = [self create:SIZE];
    [self measureBlock:^{
        employees.stream
        .peek(^(__unsafe_unretained Employee *e) {
            [e doWork];
        })
        .array();
    }];
}
- (void)testStreamConcurrent {
    NSArray<Employee *> *employees = [self create:SIZE];
    [self measureBlock:^{
        employees.stream
        .concurrent()
        .peek(^(__unsafe_unretained Employee *e) {
            [e doWork];
        })
        .array();
    }];
}

-(void)test001{
    NSArray<Employee *> *employees = [self create:SIZE];
    NSArray<NSNumber *> *array = employees.stream
    .concurrent()
    .map(^id _Nullable(__unsafe_unretained Employee *_Nonnull e) {
        return @(e.id_);
    })
    .array();
    
    BOOL a = YES;
    
    for (NSInteger i = 0, n = array.count; i < n; i++) {
        NSInteger m = array[i].integerValue;
        if (m != i) {
            a = NO;
            break;
        }
    }
    XCTAssertTrue(a);
}
-(void)test002{
    NSArray<Employee *> *employees = [self create:SIZE];
    NSArray<NSNumber *> *array = employees.stream
    .concurrent()
    .filter(^BOOL(__unsafe_unretained Employee * _Nonnull e) {
        return e.id_ < 100;
    })
    .array();
    
    XCTAssertEqual(array.count, 100);
    BOOL a = YES;

    for (Employee *e in array) {
        if (e.id_ >= 100) {
            a = NO;
            break;
        }
    }
    XCTAssertTrue(a);
}
-(void)test003{
    NSArray<Employee *> *array1 = [self create:200];
    NSArray<Employee *> *array2 = [self create:100];
    NSOrderedSet<NSNumber *> *set = array1.stream
    .add(array2)
    .map(^id _Nullable(__unsafe_unretained Employee * _Nonnull e) {
        return @(e.id_);
    })
    .set();
    
    XCTAssertEqual(set.count, 200);
    BOOL a = YES;
    
    int n = 0;
    for (NSNumber *e in set) {
        if (e.integerValue != n++) {
            a = NO;
            break;
        }
    }
    XCTAssertTrue(a);
}
-(void)test004{
    NSArray<Employee *> *array1 = [self create:200];
    NSDictionary<NSNumber *, Employee *> *dictionary = array1.stream
    .dictionary(@"id_");
    
    BOOL a = YES;

    for (NSNumber *k in dictionary.allKeys) {
        Employee *e = dictionary[k];
        if (e.id_ != k.integerValue) {
            a = NO;
            break;
        }
    }
    XCTAssertTrue(a);
}
-(void)test005{
    NSArray<Employee *> *employees = [self create:200];
    __block NSInteger a = 0;
    
    employees.stream
    .peek(^(__unsafe_unretained Employee * _Nonnull e) {
        a += [e sayOne];
    });
    
    XCTAssertEqual(a, 0);
    
    employees.stream
    .peek(^(__unsafe_unretained Employee * _Nonnull e) {
        a += [e sayOne];
    })
    .iterate();
    
    XCTAssertEqual(a, 200);
}

- (NSArray<Employee *> *)create:(NSInteger)count {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Employee *e = [[Employee alloc] init];
        e.id_ = i;
        [array addObject:e];
    }
    return array;
}
@end
