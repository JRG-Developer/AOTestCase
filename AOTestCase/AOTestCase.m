//
//  AOTestCase.m
//  AOTestCase
//
//  Created by Joshua Greene on 6/4/14.
//  Copyright (c) 2014 App-Order (http://app-order.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "AOTestCase.h"
#import <objc/runtime.h>

@interface AOTestCase()
@property (nonatomic, strong) NSTimer *timeOutTimer;
@property (nonatomic, assign) BOOL timeOut;
@end

@implementation AOTestCase

#pragma mark - Method Swizzling

- (void)swapClassMethodsForClass:(Class)cls selector:(SEL)sel1 andSelector:(SEL)sel2
{
  Method method1 = class_getClassMethod(cls, sel1);
  Method method2 = class_getClassMethod(cls, sel2);
  method_exchangeImplementations(method1, method2);
}

- (void)swapInstanceMethodsForClass:(Class)cls selector:(SEL)sel1 andSelector:(SEL)sel2
{
  Method method1 = class_getInstanceMethod(cls, sel1);
  Method method2 = class_getInstanceMethod(cls, sel2);
  method_exchangeImplementations(method1, method2);
}

#pragma mark - Asynchronous Testing

- (void)beginAsynchronousOperation
{
  self.semaphore = dispatch_semaphore_create(0);
}

- (BOOL)waitForAsyncronousOperation
{
  return [self waitForAsyncronousOperationWithTimeOut:1];
}

- (BOOL)waitForAsyncronousOperationWithTimeOut:(NSTimeInterval)seconds
{
  [self startTimeOutTimer:seconds];
  
  while(dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
    
    if (self.timeOut) {
      [self endAsynchronousOperation];
    }
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }

  [self stopTimeOutTimer];
  return !self.timeOut;
}

- (void)endAsynchronousOperation
{
  dispatch_semaphore_signal(self.semaphore);
}

#pragma mark - Time Out Timer

- (void)startTimeOutTimer:(NSTimeInterval)timeInterval
{
  self.timeOut = NO;
  self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                       target:self
                                                     selector:@selector(timedOut:)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void)timedOut:(NSTimer *)timer
{
  self.timeOut = YES;
}

- (void)stopTimeOutTimer
{
  [self.timeOutTimer invalidate];
  self.timeOutTimer = nil;
}

@end

@implementation NSObject (AOTestCase_Additions)

- (void)setAssociatedValue:(id)value key:(const void *)key
{
  objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedValueForKey:(const void *)key
{
  return objc_getAssociatedObject(self, key);
}

@end