//
//  Chapter.m
//  AePubReader
//
//  Created by Federico Frappi on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Chapter.h"
#import "NSString+HTML.h"
@implementation Chapter(private)
int tempInt;
@end

@implementation Chapter 

@synthesize delegate, chapterIndex, title, pageCount, spinePath, text, windowSize, fontPercentSize;

- (id) initWithPath:(NSString*)theSpinePath title:(NSString*)theTitle chapterIndex:(int) theIndex{
    if((self=[super init])){
        spinePath = [theSpinePath retain];
        title = [theTitle retain];
        chapterIndex = theIndex;

		NSString* html = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:theSpinePath]] encoding:NSUTF8StringEncoding];
		text = [[html stringByConvertingHTMLToPlainText] retain];
		[html release];
    }
    return self;
}

- (void) loadChapterWithWindowSize:(CGRect)theWindowSize fontPercentSize:(int) theFontPercentSize{
    fontPercentSize = theFontPercentSize;
    windowSize = theWindowSize;
    NSLog(@"webviewSize: %f * %f, fontPercentSize: %d", theWindowSize.size.width, theWindowSize.size.height,theFontPercentSize);
    UIWebView* webView = [[UIWebView alloc] initWithFrame:windowSize];
    [webView setDelegate:self];
    NSLog(@"解析的章节Path===========================%@",spinePath);
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:spinePath]];
    [webView loadRequest:urlRequest];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@", error);
	[webView dealloc];
}

- (void) webViewDidFinishLoad:(UIWebView*)webView{
    NSLog(@"已经执行--%d--次",tempInt++);
    float startTime= [[NSDate date] timeIntervalSince1970];
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
	
	NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
        "ruleIndex = mySheet.cssRules.length;"
        "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
	"}";
	
	NSLog(@"webView.bounds.size.width:%f webView.bounds.size.height:%f", webView.bounds.size.width, webView.bounds.size.height);
	
	NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
	NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
	NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')",fontPercentSize];
    
	
	[webView stringByEvaluatingJavaScriptFromString:varMySheet];
	
	[webView stringByEvaluatingJavaScriptFromString:addCSSRule];
		
	[webView stringByEvaluatingJavaScriptFromString:insertRule1];
	
	[webView stringByEvaluatingJavaScriptFromString:insertRule2];
	
    [webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
    
	int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
    NSLog(@"document.documentElement.scrollWidth=====%d",totalWidth);
    NSLog(@"webView.bounds.size.width================%f",webView.bounds.size.width);

	pageCount = (int)((float)totalWidth/webView.bounds.size.width);
	
    NSLog(@"Chapter %d: %@ -> %d pages", chapterIndex, title, pageCount);
    
    [webView dealloc];
    [delegate chapterDidFinishLoad:self];
    NSLog(@"第%d章节耗时======%f",tempInt-1,[[NSDate date] timeIntervalSince1970]-startTime);
    
}

- (void)dealloc {
    [title release];
	[spinePath release];
	[text release];
    [super dealloc];
}


@end
