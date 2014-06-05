//
//  AOTestCaseTests.m
//  AOTestCase
//
//  Created by Joshua Greene on 6/4/14.
//  Copyright (c) 2014 App-Order. All rights reserved.
//

// Test Class
#import "AOTestCase.h"

// Collaborators
#import "AOTestObject.h"

// Test Support
#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

//#define MOCKITO_SHORTHAND
//#import <OCMockito/OCMockito.h>

const char AOTestSwizzlingKey;
const char AOTestAssociationKey;

@interface AOTestObject (Test_Methods)
+ (BOOL)swizzled_classMethod;
- (BOOL)swizzled_instanceMethod;
@end

@implementation AOTestObject (Test_Methods)

+ (BOOL)swizzled_classMethod
{
  return YES;
}

- (BOOL)swizzled_instanceMethod
{
  return YES;
}

@end

@interface AOTestCaseTests : AOTestCase
@property (nonatomic, assign) NSTimeInterval timeOutInterval;
@end

@implementation AOTestCaseTests
{
  AOTestObject *testObject;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];
  testObject = [[AOTestObject alloc] init];
}

#pragma mark - Swizzled Methods

- (void)swizzled_waitForAsyncronousOperationWithTimeOut:(NSTimeInterval)timeOutSeconds
{
  self.timeOutInterval = timeOutSeconds;
}

#pragma mark - Method Swizzling - Tests

- (void)test___swapInstanceMethodsForClass_selector_andSelector___correctlySwapsInstanceMethods
{
  // given
  [self swapInstanceMethodsForClass:[AOTestObject class]
                           selector:@selector(instanceMethod)
                        andSelector:@selector(swizzled_instanceMethod)];
  
  // then
  assertThatBool([testObject instanceMethod], equalToBool(YES));
  
  
  // clean up
  [self swapInstanceMethodsForClass:[AOTestCase class]
                           selector:@selector(swizzled_instanceMethod)
                        andSelector:@selector(instanceMethod)];
}

- (void)test___swapClassMethodsForClass_selector_andSelector___correctlySwapsClassMethods
{
  // given
  [self swapClassMethodsForClass:[AOTestObject class]
                        selector:@selector(classMethod)
                     andSelector:@selector(swizzled_classMethod)];
  
  // when
  assertThatBool([AOTestObject classMethod], equalToBool(YES));
  
  // then
  [self swapClassMethodsForClass:[AOTestObject class]
                        selector:@selector(classMethod)
                     andSelector:@selector(swizzled_classMethod)];
}

#pragma mark - Asynchronous Testing - Tests

- (void)test___beginAsynchronousOperation___createsSemaphore
{
  // when
  [self beginAsynchronousOperation];
  
  // then
  assertThat(self.semaphore, notNilValue());
}

- (void)test___waitForAsyncronousOperation___calls___waitForAsyncronousOperationWithTimeOut___passing1Second
{
  // given
  [self swapInstanceMethodsForClass:[self class]
                           selector:@selector(waitForAsyncronousOperationWithTimeOut:)
                        andSelector:@selector(swizzled_waitForAsyncronousOperationWithTimeOut:)];
  
  // when
  [self waitForAsyncronousOperation];
  
  // then
  assertThatDouble(self.timeOutInterval, equalToDouble(1.0));
  
  // clean up
  [self swapInstanceMethodsForClass:[self class]
                           selector:@selector(waitForAsyncronousOperationWithTimeOut:)
                        andSelector:@selector(swizzled_waitForAsyncronousOperationWithTimeOut:)];
}

- (void)test___waitForAsyncronousOperationWithTimeOut___waitsForSemaphoreSignal
{
  // given
  [self beginAsynchronousOperation];
  __block BOOL done = NO;

  // when
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    done = YES;
    [self endAsynchronousOperation];
  });
  
  // then
  BOOL success = [self waitForAsyncronousOperationWithTimeOut:0.5];
  assertThatBool(done, equalToBool(YES));
  assertThatBool(success, equalToBool(YES));
}

- (void)test___waitForAsyncronousOperationWithTimeOut___timesOut
{
  // given
  [self beginAsynchronousOperation];
  
  // when
  BOOL success = [self waitForAsyncronousOperationWithTimeOut:0.5];
  assertThatBool(success, equalToBool(NO));
}

#pragma mark - Object Association Tests

- (void)test___setAssociatedValue_key___correctlyAssociatesValueForKey
{
  // when
  [testObject setAssociatedValue:@YES key:&AOTestAssociationKey];
  
  // then
  BOOL value = [objc_getAssociatedObject(testObject, &AOTestAssociationKey) boolValue];
  assertThatBool(value, equalToBool(YES));
  
  // clean up
  objc_setAssociatedObject(testObject, &AOTestAssociationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)test___getAssociatedValueForKey___correctlyReturnsAssociatedValue
{
  // given
  objc_setAssociatedObject(testObject, &AOTestAssociationKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  
  // when
  BOOL value = [testObject associatedValueForKey:&AOTestAssociationKey];
  
  // then
  assertThatBool(value, equalToBool(YES));
  
  // clean up
  objc_setAssociatedObject(testObject, &AOTestAssociationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end