//
//  NSHTTPCookie+Util.h
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/19.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPCookie (Util)

// 将cookie格式化为string的扩展方法
- (NSString *)xjp_formatCookieString;

@end

NS_ASSUME_NONNULL_END
