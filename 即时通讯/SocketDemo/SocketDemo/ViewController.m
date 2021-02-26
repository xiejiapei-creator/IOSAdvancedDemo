//
//  ViewController.m
//  SocketDemo
//
//  Created by 谢佳培 on 2021/2/22.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define SocketPort htons(8040)
#define SocketIP   inet_addr("127.0.0.1")

@interface ViewController ()
@property (nonatomic, assign) int clinenId;
@property (strong, nonatomic) UITextField *sendMessageContentTextField;
@property (strong, nonatomic) UITextView *allMessageContentTextView;
@property (nonatomic, strong) NSMutableAttributedString *totalAttributeString;
@property (nonatomic, copy) NSString *recoderTime;

@property (nonatomic, assign) int index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSubvies];
    
    self.allMessageContentTextView.editable = NO;
    self.totalAttributeString = [[NSMutableAttributedString alloc] init];
}

- (void)createSubvies
{
    self.allMessageContentTextView = [[UITextView alloc] initWithFrame:CGRectMake(70, 350, 300, 300)];
    self.allMessageContentTextView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.allMessageContentTextView];
    
    self.sendMessageContentTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 220, 200, 50)];
    self.sendMessageContentTextField.placeholder = @"发送消息";
    self.sendMessageContentTextField.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.sendMessageContentTextField];
    
    UIButton *connectSocketButton = [[UIButton alloc] initWithFrame:CGRectMake(100.f, 100.f, 100, 50.f)];
    [connectSocketButton addTarget:self action:@selector(socketConnetAction:) forControlEvents:UIControlEventTouchUpInside];
    [connectSocketButton setTitle:@"连接Socket" forState:UIControlStateNormal];
    [connectSocketButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    connectSocketButton.layer.cornerRadius = 5.f;
    connectSocketButton.clipsToBounds = YES;
    connectSocketButton.layer.borderWidth = 1.f;
    connectSocketButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:connectSocketButton];
    
    UIButton *sendMessageButton = [[UIButton alloc] initWithFrame:CGRectMake(320.f, 220.f, 100, 50.f)];
    [sendMessageButton addTarget:self action:@selector(sendMessageAction) forControlEvents:UIControlEventTouchUpInside];
    [sendMessageButton setTitle:@"发送消息" forState:UIControlStateNormal];
    [sendMessageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sendMessageButton.layer.cornerRadius = 5.f;
    sendMessageButton.clipsToBounds = YES;
    sendMessageButton.layer.borderWidth = 1.f;
    sendMessageButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:sendMessageButton];
}

#pragma mark - 创建socket建立连接

- (void)socketConnetAction:(UIButton *)sender
{
    
    // 创建socket
    int socketID = socket(AF_INET, SOCK_STREAM, 0);
    self.clinenId = socketID;
    if (socketID == -1)
    {
        NSLog(@"创建socket失败");
        return;
    }

    // 创建套接字地址
    struct sockaddr_in socketAddr;
    socketAddr.sin_family = AF_INET;// AF_INET（地址族）PF_INET（协议族）
    socketAddr.sin_port   = SocketPort;// 端口
    struct in_addr socketIn_addr;
    socketIn_addr.s_addr  = SocketIP;// ip
    socketAddr.sin_addr   = socketIn_addr;
    
    // 建立连接
    int result = connect(socketID, (const struct sockaddr *)&socketAddr, sizeof(socketAddr));
    if (result != 0)
    {
        NSLog(@"链接失败");
        return;
    }
    NSLog(@"链接成功");

    // 在子线程异步接收消息
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self recvMessage];
    });
}

#pragma mark - 发送消息与接收消息

// 发送消息
- (void)sendMessageAction
{
    if (self.sendMessageContentTextField.text.length == 0)
    {
        return;
    }
    
    // 计算发送的消息长度
    const char *Message = self.sendMessageContentTextField.text.UTF8String;
    ssize_t sendLength = send(self.clinenId, Message, strlen(Message), 0);
    NSLog(@"发送 %ld 字节",sendLength);
    
    // 展示发送的消息
    [self showMessage:self.sendMessageContentTextField.text MessageType:0];
    
    // 消息发送完成后清空文本框
    self.sendMessageContentTextField.text = @"";
}

// 接收消息
- (void)recvMessage
{
    // 1：通过循环的方式模拟长连接（如果不循环监听，那么发送一次消息后即断开链接）
    while (1)
    {
        uint8_t buffer[1024];
        ssize_t recvLength = recv(self.clinenId, buffer, sizeof(buffer), 0);
        
        if (recvLength == 0)
        {
            NSLog(@"接收到了0个字节");
            continue;
        }
        
        // buffer -> data -> string
        NSData *data = [NSData dataWithBytes:buffer length:recvLength];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"当前线程为：%@，接收到的信息为：%@",[NSThread currentThread],string);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 作为接收到的消息进行展示
            [self showMessage:string MessageType:1];
            // 接收到消息后清空文本框
            self.sendMessageContentTextField.text = @"";
        });
    }
}

#pragma mark - 接收信息和发送信息格式处理

- (void)showMessage:(NSString *)Message MessageType:(int)MessageType
{
    // 显示系统当前时间
    NSString *showTimeStr = [self getCurrentTime];
    if (showTimeStr)
    {
        // 将消息发送到时间添加到聊天框的文本中
        NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:showTimeStr];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;// 段落对齐方式
        [dateAttributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, showTimeStr.length)];
        
        [self.totalAttributeString appendAttributedString:dateAttributedString];
        [self.totalAttributeString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = 20.f;
    NSMutableAttributedString *attributedString;
    if (MessageType == 0)// 我发送的消息
    {
        attributedString = [[NSMutableAttributedString alloc] initWithString:Message];
        paragraphStyle.alignment = NSTextAlignmentRight;
        [attributedString addAttributes:@{
                                          NSFontAttributeName:[UIFont systemFontOfSize:15],
                                          NSForegroundColorAttributeName:[UIColor whiteColor],
                                          NSBackgroundColorAttributeName:[UIColor blueColor],
                                          NSParagraphStyleAttributeName:paragraphStyle
                                          }
                                  range:NSMakeRange(0, Message.length)];
    }
    else// 对方发送的消息
    {
        attributedString = [[NSMutableAttributedString alloc] initWithString:Message];

        [attributedString addAttributes:@{
                                          NSFontAttributeName:[UIFont systemFontOfSize:15],
                                          NSForegroundColorAttributeName:[UIColor blackColor],
                                          NSBackgroundColorAttributeName:[UIColor whiteColor],
                                          NSParagraphStyleAttributeName:paragraphStyle
                                          }
                                  range:NSMakeRange(0, Message.length)];
    }
    
    // 将发送的消息添加到聊天框的文本中
    [self.totalAttributeString appendAttributedString:attributedString];
    [self.totalAttributeString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];

    // 将聊天框的文本放到聊天框中
    self.allMessageContentTextView.attributedText = self.totalAttributeString;
}

// 显示系统当前时间
- (NSString *)getCurrentTime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    if (!self.recoderTime || self.recoderTime.length == 0)
    {
        self.recoderTime = dateString;
        return dateString;
    }
    
    NSDate *recoderDate = [dateFormatter dateFromString:self.recoderTime];
    self.recoderTime = dateString;
    NSTimeInterval timeInterval = [date timeIntervalSinceDate:recoderDate];
    NSLog(@"系统当前时间：%@，记录日期：%@，时间差：%f",date,recoderDate,timeInterval);
    if (timeInterval < 6)
    {
        return @" ";
    }
    return dateString;
}

@end

