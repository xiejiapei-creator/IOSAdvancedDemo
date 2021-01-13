//
//  RootViewController.m
//
//  Created by 谢佳培 on 2020/6/9.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "RootViewController.h"
#import "JavaScriptCoreViewController.h"
#import "WKWebViewViewController.h"
#import "UIWebViewViewController.h"
#import "JavascriptBridgeViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) NSArray *vcTitles;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.vcTitles = @[@"JavaScriptCoreDemo", @"WKWebViewViewDemo",@"UIWebViewDemo",@"JavascriptBridgeDemo"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vcTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.vcTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            JavaScriptCoreViewController *vc = [[JavaScriptCoreViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            WKWebViewViewController *vc = [[WKWebViewViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:
        {
            UIWebViewViewController *vc = [[UIWebViewViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:
        {
            JavascriptBridgeViewController *vc = [[JavascriptBridgeViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
