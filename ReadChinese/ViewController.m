//
//  ViewController.m
//  ReadChinese
//
//  Created by Ashen on 15/12/10.
//  Copyright © 2015年 Ashen. All rights reserved.
//

#import "ViewController.h"
#import "ASConvertor.h"

@interface ViewController()

@property (weak) IBOutlet NSTextField *txtShowPath;
@property (weak) IBOutlet NSTextField *txtShowOutPath;
@property (weak) IBOutlet NSScrollView *txtShowChinese;
@property (weak) IBOutlet NSButton *deleteInOneFile;
@property (weak) IBOutlet NSButton *deleteInAllFiles;
@property (weak) IBOutlet NSButton *tradition;

@property (nonatomic, strong)  NSTextView *txtView;

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

#pragma mark - action
- (IBAction)deleteInAllFiles:(NSButton *)sender {
    self.deleteInOneFile.state = 0;
}

- (IBAction)deleteInOneFile:(NSButton *)sender {
    self.deleteInAllFiles.state = 0;
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

#pragma mark - Method
- (void)showTxt:(NSMutableString *)txt {
    self.txtView.string = txt;
    self.txtShowChinese.documentView = _txtView;
}


- (void)readFiles:(NSString *)str {
    if (self.txtShowPath.placeholderString.length == 0 || self.txtShowOutPath.placeholderString.length == 0) {
        [self showTxt:[@"亲，选择路径没？" mutableCopy]];
        return;
    }
    [self showTxt:[@"开始导出" mutableCopy]];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *home = [str stringByExpandingTildeInPath];
    NSMutableString   *dataMstr = [NSMutableString string];
    NSMutableArray    *dataMSet = [NSMutableArray array];
    
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:home];
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:42];
    
    NSString *filename ;
    while (filename = [direnum nextObject]) {
        if ([[filename pathExtension] isEqualToString:@"plist"]) {
            [files addObject: filename];
        }
    }
    NSEnumerator *fileenum;
    fileenum = [files objectEnumerator];
    NSInteger chineseCount = 0;
    while (filename = [fileenum nextObject]) {
        
        NSMutableArray *dataInOneFile = [NSMutableArray array];
        
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
            
            if (self.deleteInOneFile.state) {
                if ([dataInOneFile containsObject:mStr]) { //除去本文件中重复出现的字符串
                    continue;
                }
                [dataInOneFile addObject:mStr];
            }
            
            if (self.deleteInAllFiles.state) {
                if ([dataMSet containsObject:mStr]) {  //除去所有文件中重复出现的字符串
                    continue;
                }
            }
            chineseCount++;
            [dataMSet addObject:mStr];
            isHasChineseInFile = YES;
        }
        if (!isHasChineseInFile) {
            [dataMSet removeObject:newFileName];
        }
    }
    
    for (NSString *txt in dataMSet) {
        if ([txt containsString:@"/*"] && [txt containsString:@"*/"]) {
            [dataMstr appendString:txt];
            [dataMstr appendString:@"\n"];
            continue;
        }
        [dataMstr appendString:[[txt stringByAppendingString:@"="] stringByAppendingString:                self.tradition.state ? [[ASConvertor getInstance] s2t:txt] : txt]];
        [dataMstr appendString:@";"];
        [dataMstr appendString:@"\n"];
    }
    [dataMstr writeToFile:self.txtShowOutPath.placeholderString atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"\n共有 %ld 个中文字符串\n", chineseCount];
    [finalStr appendString:dataMstr];
    [self showTxt:finalStr];
}

#pragma mark - getter / setter
- (NSTextView *)txtView {
    if (_txtView) {
        return _txtView;
    }
    _txtView = [[NSTextView alloc]initWithFrame:CGRectMake(0, 0, 335, 190)];
    [_txtView setMinSize:NSMakeSize(0.0, 190)];
    [_txtView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [_txtView setVerticallyResizable:YES];
    [_txtView setHorizontallyResizable:NO];
    [_txtView setAutoresizingMask:NSViewWidthSizable];
    [[_txtView textContainer]setContainerSize:NSMakeSize(335,FLT_MAX)];
    [[_txtView textContainer]setWidthTracksTextView:YES];
    [_txtView setFont:[NSFont fontWithName:@"Helvetica" size:12.0]];
    [_txtView setEditable:NO];
    return _txtView;
}


@end
