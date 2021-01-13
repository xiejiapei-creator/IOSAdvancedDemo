//
//  FFSessionConfiguration.h
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/18.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFSessionConfiguration : NSObject

@property (nonatomic,assign) BOOL isExchanged;// 是否交换方法
+ (FFSessionConfiguration *)defaultConfiguration;// 单例

// 交换掉NSURLSessionConfiguration的 protocolClasses方法
- (void)load;

// 还原初始化
- (void)unload;


@end

NS_ASSUME_NONNULL_END
