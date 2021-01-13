//
//  NSHTTPCookie+Util.m
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/19.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "NSHTTPCookie+Util.h"

@implementation NSHTTPCookie (Util)

// 将cookie格式化为string的扩展方法
- (NSString *)xjp_formatCookieString{
    NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",
                        self.name,
                        self.value,
                        self.domain,
                        self.path ?: @"/"];
    
    if (self.secure) {
        string = [string stringByAppendingString:@";secure=true"];
    }
    
    return string;
}

@end
