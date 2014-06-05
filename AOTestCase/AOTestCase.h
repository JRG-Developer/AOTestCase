//
//  AOTestCase.h
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

#import <XCTest/XCTest.h>

@interface AOTestCase : XCTestCase
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

/**
 *  This method uses the Objective-C Runtime to swap the CLASS methods given by the selectors. The order of the selectors isn't important.
 *
 *  @warning Make sure to call this method a second time at the end of a test to swap the methods back.
 *
 *  @param cls  The class on which the methods should be swapped
 *  @param sel1 The first selector to be swapped with the second
 *  @param sel2 The second selector to be swapped with the first
 */
- (void)swapClassMethodsForClass:(Class)cls selector:(SEL)sel1 andSelector:(SEL)sel2;

/**
 *  This method uses the Objective-C Runtime to swap the INSTANCE methods given by the selectors. The order of the selectors isn't important.
 *
 *  @warning Make sure to call this method a second time at the end of a test to swap the methods back.
 *
 *  @param cls  The class on which the methods should be swapped
 *  @param sel1 The first selector to be swapped with the second
 *  @param sel2 The second selector to be swapped with the first
 */
- (void)swapInstanceMethodsForClass:(Class)cls selector:(SEL)sel1 andSelector:(SEL)sel2;

/**
 *  This method sets `self.semaphore` to a new dispatch semaphore, to be used by `waitForAsyncronousOperation`.
 *
 *  @warning It is NOT safe to call this method if you're already waiting for an aynchronous method to complete.
 *  @note You should call this method before you call `waitForAsyncronousOperation`
 *
 */
- (void)beginAsynchronousOperation;

/**
 *  This method calls `waitForAsyncronousOperationWithTimeOut:` passing in `1` second.
 */
- (BOOL)waitForAsyncronousOperation;

/**
 * This method causes the main run loop to continue to run until `self.semaphore` is signaled (success condition) or the time out is reached (failure condition). If the time out is reached, this method will cause a test failure.
 *
 * @note It *should* be safe to call this method more than once, but you should avoid doing such (as this may be processor intensive and/or cause the main run loop to run longer than necessary).
 *
 *  @param timeOutSeconds The number of seconds to wait for the operation to complete.
 *
 *  @return Returns `YES` if `self.semaphore` was signaled (success condition) or `NO` if the time out was reached (failure condition)
 */
- (BOOL)waitForAsyncronousOperationWithTimeOut:(NSTimeInterval)timeOutSeconds;

/**
 *  This signals `self.semaphore`.
 *
 *  @note You should call this method after `waitForAsyncronousOperation` (or `waitForAsyncronousOperationWithTimeOut`) to stop the main run loop from continuing to run.
 */
- (void)endAsynchronousOperation;

@end

@interface NSObject (AOTestCase_Additions)

/**
 *  This method uses the Objective-C runtime to associate and given `value` for the given `key` with `self`.
 *
 *  @param value The value to be associated with `self` for the given `key`.
 *  @param key   The key to associate the `value` with `self`.
 */
- (void)setAssociatedValue:(id)value key:(const void *)key;

/**
 *  This method returns an assocaiated value for a given key on `self`.
 *
 *  @param key The key to lookup the associated value.
 *
 *  @return The value associated with the key.
 */
- (id)associatedValueForKey:(const void *)key;
@end