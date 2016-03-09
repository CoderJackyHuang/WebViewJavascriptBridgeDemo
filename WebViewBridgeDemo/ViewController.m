//
//  ViewController.m
//  WebViewBridgeDemo
//
//  Created by huangyibiao on 16/3/9.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"


@interface ViewController () <UIWebViewDelegate>

@property WebViewJavascriptBridge *bridge;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:webView];
  
  NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
  NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
  NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
  [webView loadHTMLString:appHtml baseURL:baseURL];

  // 开启日志
    [WebViewJavascriptBridge enableLogging];
  
  // 给哪个webview建立JS与OjbC的沟通桥梁
  self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
  [self.bridge setWebViewDelegate:self];
  [self renderButtons:webView];
  
  // JS主动调用OjbC的方法
  // 这是JS会调用getUserIdFromObjC方法，这是OC注册给JS调用的
  // JS需要回调，当然JS也可以传参数过来。data就是JS所传的参数，不一定需要传
  // OC端通过responseCallback回调JS端，JS就可以得到所需要的数据
  [self.bridge registerHandler:@"getUserIdFromObjC" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"js call getUserIdFromObjC, data from js is %@", data);
    if (responseCallback) {
      // 反馈给JS
      responseCallback(@{@"userId": @"123456"});
    }
  }];
  
  [self.bridge registerHandler:@"getBlogNameFromObjC" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"js call getBlogNameFromObjC, data from js is %@", data);
    if (responseCallback) {
      // 反馈给JS
      responseCallback(@{@"blogName": @"标哥的技术博客"});
    }
  }];
  
  [self.bridge callHandler:@"getUserInfos" data:@{@"name": @"标哥"} responseCallback:^(id responseData) {
    NSLog(@"from js: %@", responseData);
  }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  NSLog(@"webViewDidFinishLoad");
}

- (void)renderButtons:(UIWebView*)webView {
  UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
  
  UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [callbackButton setTitle:@"打开博文" forState:UIControlStateNormal];
  [callbackButton addTarget:self action:@selector(onOpenBlogArticle:) forControlEvents:UIControlEventTouchUpInside];
  [self.view insertSubview:callbackButton aboveSubview:webView];
  callbackButton.frame = CGRectMake(10, 400, 100, 35);
  callbackButton.titleLabel.font = font;
  
  UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [reloadButton setTitle:@"刷新webview" forState:UIControlStateNormal];
  [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
  [self.view insertSubview:reloadButton aboveSubview:webView];
  reloadButton.frame = CGRectMake(110, 400, 100, 35);
  reloadButton.titleLabel.font = font;
}

- (void)onOpenBlogArticle:(id)sender {
  // 调用打开本demo的博文
  [self.bridge callHandler:@"openWebviewBridgeArticle" data:nil];
}


@end
