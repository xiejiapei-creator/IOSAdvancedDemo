//
//  CustomURLProtocol.m
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/15.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "CustomURLProtocol.h"
#import "FFSessionConfiguration.h"

//定义一个字符串做key
static NSString *URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface CustomURLProtocol()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation CustomURLProtocol

#pragma mark - canInitWithRequest
// 通过该方法的返回值来筛选request是否需要被NSURLProtocol做拦截处理

// 一、加载UIWebView和WKWebView
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // 获取所有的absoluteString
    NSString *absoluteString = [[request URL] absoluteString];
    NSLog(@"absoluteString--%@",absoluteString);
    
    /* 拦截百度标题栏的logo图片，返回YES进行拦截，目的是替换为自己的海贼王图片
    if ([absoluteString isEqualToString:@"https://www.baidu.com/img/flexible/logo/plus_logo_web.png"])
    {
        return YES;
    }
    */
    
    // 直接hook所有图片：比较URL的后缀是否属于图片，是则自定义忽略掉
    NSString* extension = request.URL.pathExtension;
    NSArray *array = @[@"png", @"jpeg", @"gif", @"jpg"];
    if([array containsObject:extension]){
        return YES;
    }
 
    // 默认返回NO，不进行拦截
    return NO;
}

/* 二、加载NSURLSession和NSURLConnection
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // 发现是处理过的请求直接返回NO不拦截此请求
    if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request])
    {
        return NO;
    }
    return YES;
}
*/

// 可选方法，对需要拦截的请求进行自定的处理，没有特殊需要，则直接`return request`
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

// 用来判断两个`request`请求是否相同，这个方法基本不常用，通常只需要调用父类的实现即可
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

// 该方法会创建一个`NSURLProtocol`实例，在这里直接调用`super`的指定构造器方法，将网络请求重新发送出去
- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

#pragma mark - startLoading
// 转发的核心方法，在这里需要我们手动的把请求发出去
// 可以使用原生的NSURLConnection、NSURLSessionDataTask
// 也可以使用的第三方网络库AFNetworking

// 一、加载UIWebView和WKWebView
- (void)startLoading
{
    // 获取所有的absoluteString
    NSString *absoluteString = [[self.request URL] absoluteString];
    
    /* 拦截百度标题栏的logo图片，替换为自己本地的海贼王图片
    if ([absoluteString isEqualToString:@"https://www.baidu.com/img/flexible/logo/plus_logo_web.png"])
    {
        // 取出本地图片
        NSData *data = [self getImageData];
        // 接着调用client的didLoadData加载数据方法
        [self.client URLProtocol:self didLoadData:data];
    }
    */
    
    // 只要是图片，全部替换为海贼王
    NSString* extension = self.request.URL.pathExtension;
    NSArray *array = @[@"png", @"jpeg", @"gif", @"jpg"];
    if([array containsObject:extension])
    {
        // 图片加载的一般都是广告，实体数据有一层model包装，所以只会去除掉广告而不会打扰到实体数据
        
        // 取出本地图片
        NSData *data = [self getImageData];
        // 接着调用client的didLoadData加载数据方法
        [self.client URLProtocol:self didLoadData:data];
    }
}
//

/* 二、加载NSURLSession 和 加载NSURLConnection
- (void)startLoading
{
    // 拦截的请求的request对象
    NSMutableURLRequest *mutableReqeust = [self.request mutableCopy];
    // 标示该request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    
    //这个enableDebug随便根据自己的需求了，可以直接拦截到数据返回本地的模拟数据，进行测试
    BOOL enableDebug = NO;
    if (enableDebug)
    {
        NSString *str = @"测试数据";
        // 将NSString转换为UTF-8数据
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        // 新的response
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL
                                                            MIMEType:@"text/plain"
                                               expectedContentLength:data.length
                                                    textEncodingName:nil];
        // 将新的response作为request对应的response，不缓存
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        // 设置request对应的 响应数据 response data
        [self.client URLProtocol:self didLoadData:data];
        // 标记请求结束
        [self.client URLProtocolDidFinishLoading:self];
    }
    else
    {
        // 使用NSURLSession继续把request发送出去
        NSLog(@"自定义协议: 使用NSURLSession继续把request发送出去");
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:mainQueue];
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:self.request];
        [task resume];
    }
}
*/
// startLoading：请求被停止，完成在结束网络请求的操作
- (void)stopLoading
{
    // NSURLSession的停止方法
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma mark - NSURLSessionDelegate

// 接收到返回信息时(还未开始下载), 执行的代理方法
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSLog(@"自定义协议: 接收到返回信息时(还未开始下载)");
    // 走的是继续路线，所以需要和截取路线各自写一份client的三个方法
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

// 接收到服务器返回的数据 调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 打印返回数据
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (dataStr)
    {
        NSLog(@"自定义协议: ***截取数据***: %@", dataStr);
    }
    [self.client URLProtocol:self didLoadData:data];
}

// 请求结束或者是失败的时候调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
    {
        [self.client URLProtocol:self didFailWithError:error];
    }
    else
    {
        NSLog(@"自定义协议: 请求结束");
        [self.client URLProtocolDidFinishLoading:self];
    }
}

#pragma mark - runtime拦截AFNetworking

// 开始监听
+ (void)startMonitor
{
    // 取得单例
    FFSessionConfiguration *sessionConfiguration = [FFSessionConfiguration defaultConfiguration];
    // 注册
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    // 还没有交换就交换
    if (![sessionConfiguration isExchanged])
    {
        // 交换
        [sessionConfiguration load];
    }
}

// 停止监听
+ (void)stopMonitor
{
    // 取得单例
    FFSessionConfiguration *sessionConfiguration = [FFSessionConfiguration defaultConfiguration];
    // 当不需要拦截的时候，要进行注销
    [NSURLProtocol unregisterClass:[CustomURLProtocol class]];
    // 已经交换过了就还原
    if ([sessionConfiguration isExchanged])
    {
        // 还原
        [sessionConfiguration unload];
    }
}

#pragma mark - Private Methods

// 取出本地图片
- (NSData *)getImageData
{
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"haizeiwang.jpg" ofType:@""];
    return [NSData dataWithContentsOfFile:fileName];
}

@end
