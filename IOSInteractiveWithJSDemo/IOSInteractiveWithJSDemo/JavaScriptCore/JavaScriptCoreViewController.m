//
//  ViewController.m
//  3-JavaScriptCoreDemo
//
//  Created by 谢佳培 on 2020/6/9.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "JavaScriptCoreViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSCoreMoreObject.h"

@interface JavaScriptCoreViewController ()<UIWebViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UILabel *showLabel;

@end

@implementation JavaScriptCoreViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化webView
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    // 加载html
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"JavaScriptCore.html" withExtension:nil];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

// 加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Block中存在强持有self,所以自然要打破循环引用
    __weak typeof(self) weakSelf = self;
    
    // OC 调用 JS：设置当前网页标题为html中的document.title
    NSString *titlt = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = titlt;
    
    // JSContext
    JSContext *jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext = jsContext;
    
    // 在js中添加全局变量arr
    [self.jsContext evaluateScript:@"var arr = [5,'关羽','赵云'];"];
    
    // 在js中添加方法
    NSString *jsFunction = @"function add(a,b) {return a+b}";
    [self.jsContext evaluateScript:jsFunction];
    
    // 点击弹框
    jsContext[@"showMessage"] = ^{// 弹框方法的具体实现
        NSLog(@"调用OC中的showMessage具体实现");
        
        // 因为刚才我们设置的是全局变量 可以直接获取
        JSValue *arrValue = weakSelf.jsContext[@"arr"];
        NSLog(@"arrValue == %@",arrValue);
        int num = [[arrValue.toArray objectAtIndex:0] intValue];
        num += 10;
        NSLog(@"arrValue == %@  : num == %d",arrValue.toArray,num);

        
        // 调用刚才设置的方法
        JSValue *addResult = [self.jsContext[@"add"] callWithArguments:@[@2, @3]];
        NSLog(@"addResult = %@", @([addResult toInt32]));// 5
        
        // 调用JS中的方法，并且传入参数
        NSDictionary *dict = @{@"name":@"刘备",@"age":@22};
        [[JSContext currentContext][@"ocCalljs"] callWithArguments:@[dict]];
    };
    self.jsContext[@"showDict"] = ^(JSValue *value) {// 拿到回传值的方法
        // JS中的方法回传过来的字典值展示到label上
        NSArray *args = [JSContext currentArguments];
        JSValue *dictValue = args[0];
        NSDictionary *dict = dictValue.toDictionary;
        NSLog(@"JS中的方法回传过来的字典值：%@",dict);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.showLabel.text = dict[@"name"];
        });
    };
    
    // 打开相册
    self.jsContext[@"getImage"] = ^{
        // imagePicker需要在主线程调用，而我们的webView的加载中处于子线程
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imagePicker = [[UIImagePickerController alloc] init];
            weakSelf.imagePicker.delegate = weakSelf;
            weakSelf.imagePicker.allowsEditing = YES;
            weakSelf.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [weakSelf presentViewController:weakSelf.imagePicker animated:YES completion:nil];
        });
    };
    
    // JS 操作对象
    JSCoreMoreObject *object = [[JSCoreMoreObject alloc] init];
    self.jsContext[@"object"] = object;
    NSLog(@"JS 操作对象: object == %d",[object getSumWithNum1:20 num2:40]);
    
    // 异常处理
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"exception == %@",exception);
    };
}

#pragma mark -- UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    NSLog(@"info---%@",info);
    // 通过info信息读取原始图片的数据
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    // 0.01为这里设置的压缩系数compressionQuality
    NSData *imageData = UIImageJPEGRepresentation(resultImage, 0.01);
    
    // 先将字符串转为Data再进行64位编码
    NSString *encodedImageStr = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    // 移除空格、回车、换行
    NSString *imageString = [self removeSpaceAndNewline:encodedImageStr];
    
    // OC调用JS中显示图片的方法，并且向JS中传入OC的图片参数
    NSString *jsFunctStr = [NSString stringWithFormat:@"showImage('%@')",imageString];
    [self.jsContext evaluateScript:jsFunctStr];
    
    // 退出相册选择器
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 移除空格、回车、换行
- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *tempStr;
    // 移除空格
    tempStr = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 移除回车
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    // 移除换行
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return tempStr;
}

#pragma mark - Lazy

- (UILabel *)showLabel{
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 64+20, 100, 30)];
        _showLabel.textColor = [UIColor orangeColor];
        _showLabel.font = [UIFont systemFontOfSize:16];
        _showLabel.text = @"我是一个文本";
    }
    return _showLabel;
}

@end
