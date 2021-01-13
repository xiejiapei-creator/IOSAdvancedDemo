//
//  CustomURLProtocol.h
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/15.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomURLProtocol : NSURLProtocol

//开始监听
+(void)startMonitor;

//停止监听
+ (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
