//
//  Employee.h
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Employee : NSObject
@property (nonatomic, assign) NSInteger id_;

-(void)doWork;
-(void)sayHello;
-(NSInteger)sayOne;
@end

NS_ASSUME_NONNULL_END
