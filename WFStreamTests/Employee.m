//
//  Employee.m
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import "Employee.h"

@implementation Employee{
    
}
- (void)doWork{
    int i = 1000000;
    do{
        i = i % 2;
    }while (i > 1);
}
-(void)sayHello{
    printf("%s says Hello.\n", self.identifier.UTF8String);
}
- (NSInteger)sayOne{
    return 1;
}
@end
