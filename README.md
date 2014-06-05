#AOTestCase

`AOTestCase` subclasses `XCTestCase` and adds asynchronous test support, easy-to-use method swizzling, and a category for setting and getting associated objects.

##Installation with CocoaPods

You should add the following line to your `Tests` target within your project's `Podfile:

    pod "AOTestCase", "~> 1.0"
    
In example, your `Podfile` might look something like this:

    target "MyProject" do
        # ...some pods...
    end

    target "MyProjectTests" do
        pod "AOTestCase", "~> 1.0"
    end

##Manual Installation

Alternatively, you can manually drag and drop the `AOTestCase.h` and `AOTestCase.m` files into your project, making sure that your `Tests` target (and not the main target) is selected.

##How to Use

`AOTestCase` is designed to be a base test case class for each of your test cases:

1) Start by creating a new test case, as you normally would (e.g. from a class template).

2) `#import "AOTestCase.h` at the top of your new test case.

3) Replace `@interface TestCaseName : XCTestCase` with `@interface TestCaseName : AOTestCase` to make your test case inherit from `AOTestCase` instead of `XCTestCase`.

####Method Swizzling

`AOTestCase` makes it easy to swizzle instance or class methods:

1) Create a new category on the class that you want to swizzle:
    
    @interface AOTestObject (Test_Methods)
    - (BOOL)swizzled_instanceMethod;
    @end`

    @implementation AOTestObject (Test_Methods)
    - (BOOL)swizzled_instanceMethod
    {
      return YES;
    }
    @end

2) Use either `swapInstanceMethodsForClass...` or `swapClassMethodsForClass...` to swizzle instance or class methods respectively within one of your test methods:

    - (void)test___swapInstanceMethodsForClass
    {
        // Swizzle the instance methods
        [self swapInstanceMethodsForClass:[AOTestObject class]
                               selector:@selector(instanceMethod)
                            andSelector:@selector(swizzled_instanceMethod)];
        
        // Call the original instance methods -> calls swizzled method
       XCTAssertTrue([testObject instanceMethod]);
       
       // Switch the methods back at the end of the test
      [self swapInstanceMethodsForClass:[AOTestCase class]
                               selector:@selector(swizzled_instanceMethod)
                            andSelector:@selector(instanceMethod)];
    }

####Asynchronous Method Testing

`AOTestCase` also makes it easy to test asynchronous methods.

    - (void)test___waitForAsyncronousOperationToComplete
    {
        // First call `beginAsynchronousOperation` before the operation begins
        [self beginAsynchronousOperation];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            // Call `endAsynchronousOperation` when the operation ends
            [self endAsynchronousOperation];
        });
  
        // Call `waitForAsyncronousOperation` to wait on the operation
        // This returns `YES` if operation is ended successfully,
        // or `NO` if the operation timed out.
        BOOL success = [self waitForAsyncronousOperationWithTimeOut:1.0];
        XCTAssertTrue(success);
    }
    
####Object Association at Runtime

Associating objects at runtime is easy too, thanks to the included `AOTestCase_Additions` category on `NSObject`:

To associate an object, simply call `setAssociatedValue:key:`, making sure to pass in a `const char` variable by reference as the key:

    const char AOTestAssociationKey;
    [testObject setAssociatedValue:@YES key:&AOTestAssociationKey];
        
Retrieving the value of an associated key is just as easy by calling `associatedValueForKey:` and passing the same `const char` variable by reference as the key:

    BOOL value = [testObject associatedValueForKey:&AOTestAssociationKey];
    // value == YES

##Project Objectives

Main Objective:
- To make it as easy as possible to unit test your code.

Secondary Objectives:
- Document everything (100% documentation for all header files)
- Unit test everything (100% unit testing of all code lines)

##Contributing

Bug fixes and additions are welcome! 

In order to contribute:

1) Fork this repository
2) Make your code changes
3) Add unit tests (using XCTest or <a href="https://github.com/hamcrest/OCHamcrest">OCHamcrest</a> matchers)
4) Add documentation (inline <a href="https://github.com/tomaz/appledoc">appledoc</a>-styled comments)
5) Submit a pull request

If you've never written unit tests before, that's okay! You can learn by checking out Jon Reid's (<a href="https://twitter.com/qcoding">@qcoding</a>) excellent <a href="http://qualitycoding.org/">website</a>, including a <a href="http://qualitycoding.org/unit-testing/">section just about unit testing</a>.

As this project is part of the CocoaPods specs repo, documentation web pages are automatically generated for it on <a href="cocoadocs.org">CocoaDocs</a>, parsed from the inline appledoc comments. 

If you're new to appledoc, check out Mattt Thompson's (<a href="https://twitter.com/mattt">@matt</a>) introductory <a href="http://nshipster.com/documentation/">post about it</a>.

##License

`AOTestCase` is available under the MIT license (see the `LICENSE` file for more details).