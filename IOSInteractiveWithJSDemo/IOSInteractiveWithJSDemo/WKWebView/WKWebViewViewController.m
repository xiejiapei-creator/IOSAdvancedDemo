//
//  ViewController.m
//  2-WKWebView
//
//  Created by 谢佳培 on 2020/6/9.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "WKWebViewViewController.h"
#import <WebKit/WebKit.h>

@interface WKWebViewViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, strong, readwrite) WKWebView *wkWebView;

@end

@implementation WKWebViewViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OC调用showAlert" style:UIBarButtonItemStylePlain target:self action:@selector(didClickRightItemAction)];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    // 调整按钮大小适应APP页面
    configuration.userContentController = [self wkwebViewScalPreferences];
    
    // 创建wkWebView
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    self.wkWebView.UIDelegate  = self;
    self.wkWebView.navigationDelegate = self;
    [self.view addSubview:self.wkWebView];
    
    // 加载js文件
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"WKWebView.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.wkWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
}

// 循环引用：self - webView - configuration - userContentController - self
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // html5中需要添加window.webkit.messageHandlers.<name>.postMessage(<messageBody>)方法，来实现js与oc之间的桥梁
    [self.wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"messgaeOC"];
}

// 需要根据name移除所注入的scriptMessageHandler来打破循环引用, 否则不会调用到dealloc方法
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"messgaeOC"];
}

- (void)dealloc
{
    NSLog(@"dealloc:溜了溜了");
}

#pragma mark - Event

- (void)didClickRightItemAction
{
    // JS方法
    // alert('我是一个可爱的弹框 \n'+messgae+'\n'+arr[1]);
    // arr[1]来自在我们在页面加载完成后定义的全局变量arr
    // msg: 我是一个可爱的弹框 登陆成功 谢佳培
    NSString *jsStr = [NSString stringWithFormat:@"showAlert('%@')",@"嗨，这是通过OC调用showAlert方法哦"];
    
    // OC 调用 JS方法
    [self.wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // OC 调用 JS方法: token----(null)
        // Token是服务端生成的一串字符串，以作客户端进行请求的一个令牌，
        // 当第一次登录后，服务器生成一个Token便将此Token返回给客户端，以后客户端只需带上这个Token前来请求数据即可，无需再次带上用户名和密码。
        // 使用Token的目的：Token的目的是为了减轻服务器的压力，减少频繁的查询数据库，使服务器更加健壮。
        NSLog(@"OC 调用 JS方法: %@----%@",result, error);
    }];
}

#pragma mark - WKNavigationDelegate

// 拦截网页的跳转链接: 在发送请求之前，决定是否跳转
// 点击提交按钮的时候会调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // URL = @"lgedu://jsCallOC?username=Cooci&password=123456"
    // 获取请求的URL
    NSURL *URL = navigationAction.request.URL;
    // 获取URL Scheme，其作用为方便app之间互相调用而设计的
    NSString *scheme = [URL scheme];
    
    // 拦截lgedu
    if ([scheme isEqualToString:@"lgedu"])
    {
        // url是地址, 在某个主机目录下的文件的唯一标识符（统一资源定位符url）
        // domain是域名, 比如baidu.com就是域名，而其对应的ip地址指向了百度的服务器
        // host是主机, 默认情况http协议是80端口 https协议是443端口
        NSString *host = [URL host];
        
        // 主机名为jsCallOC
        if ([host isEqualToString:@"jsCallOC"])
        {
            // 解析URL
            NSMutableDictionary *temDict = [self decoderUrl:URL];
            NSString *username = [temDict objectForKey:@"username"];
            NSString *password = [temDict objectForKey:@"password"];
            // 用户名和密码：谢佳培------123456
            NSLog(@"用户名和密码：%@------%@",username,password);
        }
        else
        {
            NSLog(@"不明地址 %@",host);
        }
        // 不允许跳转
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    // 允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // 导航栏标题
    self.title = webView.title;
    // 定义一个全局变量 arr
    NSString *jsStr = @"var arr = [5, '谢佳培', 'xiejiapei']; ";
    [self.wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // 页面加载完成之后调用, 定义一个全局变量 arr: (null)----(null)
        NSLog(@"页面加载完成之后调用, 定义一个全局变量 arr: %@----%@",result, error);
    }];
}

#pragma mark - WKUIDelegate

// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    // 使用OC样式的弹出警告框，覆盖JS的丑陋样式
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *knowAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 回调完成
        completionHandler();
    }];
    [alert addAction:knowAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (message.name)
    {
        // OC 层面的消息
    }
    
    // message == messgaeOC --- 青春气息
    NSLog(@"消息是：%@ --- %@",message.name,message.body);
}

#pragma mark - Private Methods

// 解析URL地址
- (NSMutableDictionary *)decoderUrl:(NSURL *)URL
{
    // URL = @"lgedu://jsCallOC?username=谢佳培&password=123456"
    // 分开参数
    NSArray *params = [URL.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    
    for (NSString *param in params)
    {
        // 分开键值对
        NSArray *dictArray = [param componentsSeparatedByString:@"="];
        
        if (dictArray.count > 1)
        {
            /** 网络请求拼接中文参数,用户名登陆等很多地方会用到中文,UTF8编码显得颇为重要
             *  编码:
             *  NSString* hStr =@"你好啊";
             *  NSString* hString = [hStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
             *  NSLog(@"hString === %@",hString); // hString === %E4%BD%A0%E5%A5%BD%E5%95%8A
             *
             *  解码：
             *  NSString*str3 =@"\u5982\u4f55\u8054\u7cfb\u5ba2\u670d\u4eba\u5458\uff1f";
             *  NSString*str5 = [str3 stringByRemovingPercentEncoding];
             *  NSLog(@"str5 ==== %@",str5);// str5 ====如何联系客服人员？
             */
            // 取值, 中文解码
            NSString *decodeValue = [dictArray[1] stringByRemovingPercentEncoding];
            // 解码后放入tempDic
            [tempDic setObject:decodeValue forKey:dictArray[0]];
        }
    }
    
    return tempDic;
}

// 调整按钮大小适应APP页面
- (WKUserContentController *)wkwebViewScalPreferences
{
    // js注入: json调整按钮大小脚本
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    /** WKUserScript就是帮助我们完成JS注入的类，它能帮助我们在页面填充前或js填充完成后调用
     * 参数1:脚本的源代码
     * 参数2:脚本应注入网页的时间，是个枚举,End表示：在文档完成加载之后，但在其他子资源完成加载之前插入脚本
     * 参数3:是否加入所有框架，还是只加入主框架
     */
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUserContentController = [[WKUserContentController alloc] init];
    [wkUserContentController addUserScript:wkUserScript];
    
    return wkUserContentController;
}

@end
