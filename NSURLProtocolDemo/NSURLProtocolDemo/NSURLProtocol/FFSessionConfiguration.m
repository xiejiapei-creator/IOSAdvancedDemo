//
//  FFSessionConfiguration.m
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/18.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "FFSessionConfiguration.h"
#import <objc/runtime.h>
#import "CustomURLProtocol.h"

@implementation FFSessionConfiguration

// 单例
+ (FFSessionConfiguration *)defaultConfiguration
{
    static FFSessionConfiguration *staticConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticConfiguration = [[FFSessionConfiguration alloc] init];
    });
    return staticConfiguration;
}

// 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isExchanged = NO;
    }
    return self;
}

// 交换掉 NSURLSessionConfiguration的protocolClasses方法
- (void)load
{
    // 是否交换方法 YES
    self.isExchanged = YES;
    // NSURLSessionConfiguration
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    
    // 将NSURLSessionConfiguration 和 FFSessionConfiguration中的protocolClasses方法进行交换
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
}

// 还原初始化
- (void)unload
{
    // 是否交换方法 NO
    self.isExchanged = NO;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    // 再替换一次就回来了
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
}

// 交换两个方法，此处运用到runtime
- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub
{
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);
    
    // 有一个找不到就抛出异常
    if (!originalMethod || !stubMethod)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    
    // 交换二者的实现方法，即方法混淆
    method_exchangeImplementations(originalMethod, stubMethod);
}

// 如果还有其他的监控protocol，也可以在这里加进去
// 此处用到了CustomURLProtocol
- (NSArray *)protocolClasses
{
    return @[[CustomURLProtocol class]];
}

@end
