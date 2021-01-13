//
//  NSHTTPCookieStorage+CookieUtil.m
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/22.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "NSHTTPCookieStorage+CookieUtil.h"
#import <objc/runtime.h>

@implementation NSHTTPCookieStorage (CookieUtil)

#pragma mark - 替换方法

/**
*  方法替换。Method Swizzling技术。使类中的方法实现和自己的方法实现互换，达到替换默认，且还可以调用默认方法的目的。
*
*  @param class            替换的方法所属的类
*  @param originalSelector 原始的方法选择器
*  @param swizzledSelector 用以替换的方法选择器
*/
static inline void class_methodSwizzling(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // 如果可以在原有类中添加方法，说明原有的类并没有实现，可能是继承自父类的方法。
    // 那么，我们添加一个方法，方法名为原方法名，实现为我们自己的实现。之后再将自己的方法替换成原始的实现。
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    //这么做，避免了替换方法时，由于本class中没有实现，从而替换了父类的方法。造成不可预知的错误。
    if (didAddMethod)
    {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    // 如果类中已经实现了这个原始方法，那么就与我们的方法互换一下实现即可。
    else
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - 调用

// 加载
+ (void)load
{
    class_methodSwizzling(self, @selector(cookies), @selector(custom_cookies));
}

// 自定义cookies
- (NSArray<NSHTTPCookie *> *)custom_cookies
{
    // 获取到之前的所有cookies
    NSArray *cookies = [self custom_cookies];
    BOOL isExist = NO;
    
    // 寻找Custom_Client_Cookie
    for (NSHTTPCookie *cookie in cookies)
    {
        if ([cookie.name isEqualToString:@"Custom_Client_Cookie"])
        {
            isExist = YES;
            break;
        }
    }
    
    // 寻找不到则向CookieStroage中添加
    if (!isExist)
    {
        // 添加到NSHTTPCookieStorage，其中fetchAccessTokenCookie为创建新Cookie的方法
        NSHTTPCookie *cookie = [self fetchAccessTokenCookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        
        // 添加到返回数组中
        NSMutableArray *mutableCookies = cookies.mutableCopy;
        [mutableCookies addObject:cookie];
        cookies = mutableCookies.copy;
    }
    
    return cookies;
}

// 创建新Cookie
- (NSHTTPCookie *)fetchAccessTokenCookie
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:@"Custom_Client_Cookie" forKey:NSHTTPCookieName];
    [properties setObject:@"xiejiapei" forKey:NSHTTPCookieValue];
    [properties setObject:@"" forKey:NSHTTPCookieDomain];
    [properties setObject:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie *accessCookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    return accessCookie;
}

@end
