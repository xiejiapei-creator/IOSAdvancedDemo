//
//  WKCookieManager.m
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/19.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "WKCookieManager.h"
#import "NSHTTPCookie+Util.h"

@implementation WKCookieManager

#pragma mark - Life Circle

// 单例
+ (instancetype)shareManager
{
    // 静态局部变量
    static WKCookieManager *_instance;
    // 通过dispatch_ once方式确保instance在多线程环境下只被创建一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 创建实例
        // super: 不能使用self,否则重写的allocWithZone第一次初始化的时候 会循环调用instance
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

// 重写方法[必不可少]
// 规避逃脱sharedInstance再去创建其他对象，当alloc的时候只能返回单例
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self shareManager];
}

#pragma mark - Cookie 丢失问题

// 解决新的跳转 Cookie 丢失问题
- (NSURLRequest *)fixNewRequestCookieWithRequest:(NSURLRequest *)originalRequest
{
    // 如果`navigationAction.request`是`NSURLRequest`，不可变，那不就添加不了`Cookie`了
    // 所以我们这里需要让它可变
    NSMutableURLRequest *fixedRequest;
    if ([originalRequest isKindOfClass:[NSMutableURLRequest class]])
    {
        // 里氏替换原则：父类可以被子类无缝替换，且原有功能不受影响
        // 例如：KVO实现原理，调用addObserver方法，系统在动态运行时候为我们创建一个子类，我们虽然感受到的是使用原有的父类，实际上是子类
        fixedRequest = (NSMutableURLRequest *)originalRequest;
    }
    else
    {
        // 只需要进行可变拷贝即可
        fixedRequest = originalRequest.mutableCopy;
    }
    
    // 关键步骤：防止Cookie丢失
    // 前提是保证sharedHTTPCookieStorage中你的Cookie存在
    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    if (dict.count)
    {
        NSMutableDictionary *mDict = originalRequest.allHTTPHeaderFields.mutableCopy;
        [mDict setValuesForKeysWithDictionary:dict];
        fixedRequest.allHTTPHeaderFields = mDict;
    }
    return fixedRequest;
}

// Ajax请求（局部页面更新请求）Cookie 丢失问题
- (WKUserScript *)futhureCookieScript
{
    // 只读属性，表示JS是否应该注入到所有的frames中还是只有main frame
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:[self cookieString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    return cookieScript;
}

- (NSString *)cookieString
{
    NSMutableString *script = [NSMutableString string];
    [script appendString:@"var cookieNames = document.cookie.split('; ').map(function(cookie) { return cookie.split('=')[0] } );\n"];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {

        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        [script appendFormat:@"if (cookieNames.indexOf('%@') == -1) { document.cookie='%@'; };\n", cookie.name, cookie.xjp_formatCookieString];
    }
    return script;
}

@end
