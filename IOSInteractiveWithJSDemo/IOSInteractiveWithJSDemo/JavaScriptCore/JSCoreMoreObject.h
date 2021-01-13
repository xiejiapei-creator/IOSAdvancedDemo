//
//  JSCoreMoreObject.h
//  3-JavaScriptCoreDemo
//
//  Created by 谢佳培 on 2020/6/11.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

// 在协议中声明的API都会在JS中暴露出来，才能调用
@protocol JSCoreMoreProtocol <JSExport>

- (void)letShowImage;
// PropertyName随便起 - Selector
JSExportAs(getSum, -(int)getSumWithNum1:(int)num1 num2:(int)num2);

@end

@interface JSCoreMoreObject : NSObject<JSCoreMoreProtocol>

@end

NS_ASSUME_NONNULL_END
