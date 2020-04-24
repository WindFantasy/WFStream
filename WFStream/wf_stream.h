//
//  wf_stream.h
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import <Foundation/Foundation.h>
#include <stdio.h>

NS_ASSUME_NONNULL_BEGIN

@class WFStreamImpl;
/**
 WFStream allows you to create sequential stream from NSArray. Just like JAVA dose!
 
 A sequential stream is like to putting elements into an operation pipeline. Operations are taken place one by
 one on each of the elements.
 
 Do code elegantly!
 */
class WFStream {
    WFStreamImpl *_impl;
public:
    WFStream(WFStreamImpl *impl);
    
    /**
     Returns a stream consisting of the results of applying the given function to the elements of this stream.
     
     This is an intermediate operation. You are allowed to return nil in your mapper, the result will be ignored
     in that case.
     
     @param mapper a function to apply to each element.
     */
    WFStream map(_Nullable id (^mapper)(__unsafe_unretained id e));
    
    /**
     Returns a stream consisting of the elements of this stream, additionally performing the provided action on
     each element as elements are consumed from the resulting stream.
     
     This is an intermediate operation.
     
     @param action  an action to perform on the elements as they are consumed from the stream.
    */
    WFStream peek(void (^action)(__unsafe_unretained id e));
    
    /**
     Returns a stream consisting of the elements of this stream that match the given predicate.
     
     This is an intermediate operation.
     
     @param predicate a predicate to apply to each element to determine if it should be included.
     */
    WFStream filter(BOOL (^predicate)(__unsafe_unretained id e));
    
    /**
     Returns an array consisting of the elements of this stream.
     */
    NSArray *array();
    
    /**
     Returns a set constructed by the elements of this stream.
     */
    NSOrderedSet *set();
    /**
     Returns a dictionary constructed by the elements of this stream.
     
     The function will use the value of the specified property of each element as the key and element as
     object. If the keys are duplicated, then the latest one will override the previous. It is a good idea to use
     this function to build dictionary for looking up a element by its identifier property.
     
     @param propertyName the name of the property, which's values are used as the keys of the
     dictionary.
     */
    NSDictionary *dictionary(NSString *propertyName);
    
    /**
     Iterate the stream and trigger this stream to invoke intermediate operations immediately.
     */
    void iterate();
    
    /**
     Return a stream whose elements are all the elements of the itself followed by all the elements of the
     array.
     */
    WFStream add(NSArray *array);
    
    /**
     To tell the stream to iterate concurrently during collect operations.
     
     The basic idea is to break the stream source into several sub-sources and then process them
     concurrently. Finally the stream collects them in order synchronizely.
     */
    WFStream concurrent();
};

@interface NSArray (WFStream)
@property (nonatomic, readonly) WFStream stream;
@end

NS_ASSUME_NONNULL_END
