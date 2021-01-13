//
//  WKCookieManager.h
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/19.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKCookieManager : NSObject

// 单例
+ (instancetype)shareManager;

/**
 解决新的跳转 Cookie 丢失问题
 @param originalRequest 拦截的请求
 @return 带上 Cookie 的新请求
 */
- (NSURLRequest *)fixNewRequestCookieWithRequest:(NSURLRequest *)originalRequest;

/**
 Ajax请求（局部页面更新请求）Cookie 丢失问题
 @return 注入的 JS 代码块
 */
- (WKUserScript *)futhureCookieScript;

@end

NS_ASSUME_NONNULL_END
