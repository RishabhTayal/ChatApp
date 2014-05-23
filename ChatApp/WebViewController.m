//
//  WebViewController.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/23/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "WebViewController.h"


@interface WebViewController ()

@property (strong) IBOutlet UIWebView* webView;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end