# WFStream - Doing Sequential Stream Things Like JAVA.

WFStream allows you to create sequential stream Just like JAVA dose! 

A sequential stream is like to putting elements into an operation pipeline. 
Operations are taken place one by one on each of the elements.

Do code elegantly!

## Installation

### CocoaPods

```ruby
pod 'WFStream', :git => 'https://github.com/WindFantasy/WFStream.git'
```

### Manual

1. Download the WFStream repository
2. Copy the WFStream sub-folder into your Xcode project

## Setup

Since WFStream take the advantage of C++ to perform the dot (.) notation 
invocation. You have to change the extension of the source file from `.m` to 
`.mm` to order to let the compiler handle the C++ code correctly without 
complain.

**Note**: Normally xcode would handle `.mm` extension automatically. However, 
sometimes certain xocde features (eg. syntax coloring, auto-completion) may die 
after rename. You may need to restart xcode to re-enable these featuers in this 
case (so far knowing xcode 11 has this trouble).

## Basic Usage

A typical usage may look like this:

```objc
NSArray<Employee *> *hrOffiers = ...;
NSArray<Employee *> *finantialOffiers = ...;
NSArray<Employee *> *developers = ...;

NSArray<NSArray *> *employeeIds = finantialOffiers.stream
.filter(^BOOL(Employee *e) {
    return !e.isHrOfficier;
})
.add(hrOffiers)
.add(developers)
.map(^id(Employee *e) {
    return e.identifier;
})
.array();
```

WFStream has two sets of operations: 

- Intermediate Operation

Performs action on each elements of a stream. Itermediate operations are 'lazy'. 
They would delay to perform action until a collect operation is invoked. By 
doing this each elements are handled by a pipeline of operations. This would 
minimize the number of iterations.

### Filter

Returns a stream consisting of the elements of this stream that match the given 
predicate. A preication should tell if a element should be included.

```objc
NSArray<Employee *> *NonHrFinantialOfficers = finantialOffiers.stream
.filter(^BOOL(Employee *e) {
    return e.isHrOfficier;
})
.array();
```

### Mapper

Returns a stream consisting of the results of applying the given function to the 
elements of this stream. You are allowed to return nil in your mapper, the 
result will be ignored in that case.

```objc
NSArray<NSString *> *developerIdentifiers = developers.stream
.map(^id(Employee *e) {
    return e.identifier;
})
.array();
```

### Peek

Returns a stream consisting of the elements of target stream, additionally 
performing a provided action on each element.

```objc
finantialOffiers.stream
.peek(^(Employee *e) {
    [e sayHello];
})
.iterate();
```

- Collect Operation

Collects the elements of the stream into an Objetive-C collection (NSArray, 
NSSet, NSDictionary). Collect Operation will trigger the stream to perform 
intermediate operations.

### Array

Collects the elements of a stream and stores them to an NSArray.

### Set

Collects the elements of a stream and stores them to an NSSet.

```objc
NSSet<Employee *> *distinct = finantialOffiers.stream
.add(hrOffiers)
.set();
```

### Dictionary

Collects the elements of a stream and stores them to an NSDictionary. The 
operation will use the value of the specified property of each element as the 
key and element as object. 

```objc
// Suppose we want to build a dictionray to look up an employee by a given
// identifier.
NSDictionary<NSString *, Employee *> *developerDictionary = developers.stream
.dictionary(@"identifier");
```

### Iterate

Iterate the stream and trigger this stream to invoke intermediate operations immediately 
(See code block of [Peek](#peek)).

## Performance

Elegance comes at a price. Streams invoke overheads, sometimes they consume 10 times 
more than simple for-loops (eg. lightweight process with small data set). WFStream provide
concurrent computation solution to handle performance problem.

### Concurrency

The concurrency strategy is to break the stream source into several sub-sources and then
process them concurrently. Finally the stream collects them in order synchronizely.

```objc
// let say we have 10,000,000 developer records ...
developers.stream
.concurrent()
.peek(^(Employee *e) {
    [e doHeavyWork];
})
.iterate();
```
Concurrency has better performance then for-loops. Especially for heavy computation. 
However, concurrency always attack developers. You are responsible to make sure the 
itermediate operations not going to cause synhronization problems. Operations interact 
each other or dependently are not good for concurrent streams.   

### Performance Suggestions

| Intermediate Op | Stream Size | Suggestions |
|---|---|---|
| heavy | big | For-loop / Concurrent Stream |
| heavy | small | Stream / Concurrent Stream |
| light | big | For-loop / Concurrent Stream |
| light | small | Stream |


- You don't need to worry about performance issue when dealing with small data set.
- If intermediate ops have no synchronize problem or you could deal with it by yourselves, 
concurrent stream normally run faster than for-loops for huge data set.

**A pratical suggestion: DO NOT worry about the performance problem. Until you feel 
something and then try concurrent streams; Until you found synchronization 
problems and you don't familiar and then try for-loops instead.**

## License

MIT licensed - see [LICENSE](LICENSE) file.
