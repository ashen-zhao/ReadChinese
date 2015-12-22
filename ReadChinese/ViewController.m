//
//  ViewController.m
//  ReadChinese
//
//  Created by Ashen on 15/12/10.
//  Copyright © 2015年 Ashen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()

@property (weak) IBOutlet NSTextField *txtShowPath;
@property (weak) IBOutlet NSTextField *txtShowOutPath;
@property (weak) IBOutlet NSScrollView *txtShowChinese;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtShowPath.editable = NO;
    self.txtShowOutPath.editable = NO;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)OpenFile:(NSButton *)sender {
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setCanChooseDirectories:YES];
    [oPanel setCanChooseFiles:NO];
    if ([oPanel runModal] == NSOKButton) {
        NSString *path = [[[[[oPanel URLs] objectAtIndex:0] absoluteString] componentsSeparatedByString:@":"] lastObject];
        path = [[path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByExpandingTildeInPath];
        if (sender.tag == 100) {
            self.txtShowPath.placeholderString = path;
        } else {
            self.txtShowOutPath.placeholderString = [path stringByAppendingPathComponent:@"chinese.txt"];
        }
    }
}

- (IBAction)exportAction:(id)sender {
    [self readFiles:self.txtShowPath.placeholderString];
}

- (void)readFiles:(NSString *)str {
    if (self.txtShowPath.placeholderString.length == 0 || self.txtShowOutPath.placeholderString.length == 0) {
        NSLog(@"选择路径吧");
        return;
    }
    NSLog(@"开始导出");
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *home = [str stringByExpandingTildeInPath];
    NSMutableString *dataMstr = [NSMutableString string];
    NSMutableArray    *dataMSet = [NSMutableArray array]; //由于集合无序性，这里还是用数组
    
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:home];
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:42];
    
    NSString *filename ;
    while (filename = [direnum nextObject]) {
        if ([[filename pathExtension] isEqualToString:@"m"]) {
            [files addObject: filename];
        }
    }
    NSEnumerator *fileenum;
    fileenum = [files objectEnumerator];
    NSInteger chineseCount = 0;
    while (filename = [fileenum nextObject]) {
        
        NSString *str=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", home, filename] encoding:NSUTF8StringEncoding error:nil];
        
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"@\"[^\"]*[\\u4E00-\\u9FA5]+[^\"\\n]*?\"" options:NSRegularExpressionCaseInsensitive error:nil];
    
        NSArray *matches = [regular matchesInString:str
                                            options:0
                                              range:NSMakeRange(0, str.length)];
        

        NSString *newFileName =  [NSString stringWithFormat:@"\n/*\n%@\n*/", [[filename componentsSeparatedByString:@"/"] lastObject]];
        BOOL isHasFileName = NO;
        BOOL isHasChineseInFile = NO;
        for (NSTextCheckingResult *match in matches) {
            if (!isHasFileName) {
                [dataMSet addObject:newFileName];
            }
            NSRange range = [match range];
            NSString *mStr = [str substringWithRange:range];
            NSRange isOnlyAt = NSMakeRange(0, 1);
            mStr = [mStr stringByReplacingCharactersInRange:isOnlyAt withString:@""];
            
            isHasFileName = YES;
            
            if ([dataMSet containsObject:mStr]) {  //加上这句除去，重复出现的字符串
                continue;
            }
            chineseCount++;
            [dataMSet addObject:mStr];
            isHasChineseInFile = YES;
        }
        if (!isHasChineseInFile) {
            [dataMSet removeObject:newFileName];
        }
    }

    NSLog(@"共有 %ld 个中文字符串", chineseCount);
    for (NSString *txt in dataMSet) {
        if ([txt containsString:@"/*"] && [txt containsString:@"*/"]) {
            [dataMstr appendString:txt];
            [dataMstr appendString:@"\n"];
            continue;
        }
        [dataMstr appendString:[[txt stringByAppendingString:@"="] stringByAppendingString:txt]];
        [dataMstr appendString:@";"];
        [dataMstr appendString:@"\n"];
    }
    [dataMstr writeToFile:self.txtShowOutPath.placeholderString atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self showTxt:dataMstr];
    NSLog(@"导出完成");
}

- (void)showTxt:(NSMutableString *)txt {
    NSTextView *txtView =     [[NSTextView alloc]initWithFrame:CGRectMake(0, 0, 335, 190)];
    [txtView setMinSize:NSMakeSize(0.0, 190)];
    [txtView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [txtView setVerticallyResizable:YES];
    [txtView setHorizontallyResizable:NO];
    [txtView setAutoresizingMask:NSViewWidthSizable];
    [[txtView textContainer]setContainerSize:NSMakeSize(335,FLT_MAX)];
    [[txtView textContainer]setWidthTracksTextView:YES];
    [txtView setFont:[NSFont fontWithName:@"Helvetica" size:12.0]];
    [txtView setEditable:NO];
    txtView.string = txt;
    self.txtShowChinese.documentView = txtView;
}

@end
