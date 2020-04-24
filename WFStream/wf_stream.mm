//
//  wf_stream.mm
//  WFStream
//
//  Created by Jerry on 2020/4/24.
//

#import "wf_stream.h"
#import "WFStreamOperation.h"
#import "WFStreamImpl.h"

WFStream::WFStream(WFStreamImpl *impl){
    _impl = impl;
}
WFStream WFStream::map(id (^mapper)(id e)){
    [_impl map:mapper];
    return *this;
}
WFStream WFStream::peek(void (^action)(id e)){
    [_impl peek:action];
    return *this;
}
WFStream WFStream::filter(BOOL (^predicate)(id e)){
    [_impl filter:predicate];
    return *this;
}
NSArray *WFStream::array(){
    return [_impl toArray];
}
NSOrderedSet *WFStream::set(){
    return [_impl toSet];
}
NSDictionary *WFStream::dictionary(NSString *propertyName){
    return [_impl toDictionary:propertyName];
}
void WFStream::iterate(){
    [_impl iterate];
}
WFStream WFStream::add(NSArray *array){
    return WFStream([_impl add:array]);
}

WFStream WFStream::concurrent(){
    _impl.groups = NSProcessInfo.processInfo.activeProcessorCount;
    return *this;
}

@implementation NSArray (WFStream)
- (WFStream)stream{
    WFStreamImpl *stream = [[WFStreamImpl alloc] initWithSource:self];
    return WFStream(stream);
}
@end
