//
//  main.m
//  genpro
//
//  Created by Ingo Böhme on 01.07.15.
//  Copyright © 2015 IBMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtendNSLog.h"

#define SNIPPET_RELATIVE_DIRECTORY  @"Library/Developer/Xcode/UserData/CodeSnippets"




BOOL startsWith(NSString *string, NSString *start) {
    return YES;
}

NSString *allTrim(NSString *string) {
    NSInteger i = 0;
    
    while ((i < [string length])
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[string characterAtIndex:i]]) {
        i++;
    }
    return [[string substringFromIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

void saveSnippet(NSString *prefix, NSString *protocolName,  NSString *content) {
    NSUUID *uuid = [NSUUID UUID];
    protocolName = allTrim(protocolName);
    NSMutableDictionary *snippet = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *identifier = uuid.UUIDString;
    
    [snippet setObject:[NSString stringWithFormat:@"DELE %@", protocolName] forKey:@"IDECodeSnippetCompletionPrefix"];
    [snippet setObject:@[@"TopLevel"] forKey:@"IDECodeSnippetCompletionScopes"];
    [snippet setObject:content forKey:@"IDECodeSnippetContents"];
    
    [snippet setObject:identifier forKey:@"IDECodeSnippetIdentifier"]; // 7719618F - AAA3 - 4B95 - A206 - 39E681052061 < / string >
    
    [snippet setObject:@"Xcode.SourceCodeLanguage.Objective-C" forKey:@"IDECodeSnippetLanguage"];
    
    [snippet setObject:@"Delegate defines" forKey:@"IDECodeSnippetSummary"];
    
    [snippet setObject:[NSString stringWithFormat:@"%@ Delegate", protocolName] forKey:@"IDECodeSnippetTitle"];
    
    [snippet setObject:@YES forKey:@"IDECodeSnippetUserSnippet"];
    
    [snippet setObject:@2 forKey:@"IDECodeSnippetVersion"];
    
    
    NSString *filename = [NSString stringWithFormat:@"%@/%@/%@.codesnippet", NSHomeDirectory(), SNIPPET_RELATIVE_DIRECTORY, protocolName];
    [snippet writeToFile:filename atomically:YES];
    printf(".");
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        // insert code here...
        
        NSString *xcodePath = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/UIKit.framework/Headers";
        
        printf("\nChecking UIKit framework header files for protocols/delegates\n");
        
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:xcodePath error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.h'"];
        NSArray *onlyHeader = [dirContents filteredArrayUsingPredicate:fltr];
        NSLog(@"AllFiles: %@", onlyHeader);
        
        for (NSString *fileName in onlyHeader) {
            NSString *filepath = [xcodePath stringByAppendingPathComponent:fileName];
            NSString *c = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
            NSArray *ca = [c componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSString *protocolName = @"";
            BOOL isProtocol = NO;
            BOOL isRequired = NO;
            BOOL isOptional = NO;
            //            BOOL isComment  = NO;
            //            BOOL isEmpty    = NO;
            //            BOOL isDeclaration  = NO;
            
            BOOL hasProtocol = NO;
            
            NSMutableArray *snippetLines = [NSMutableArray arrayWithCapacity:0];
            
            NSLog(@"#!************* File: %@", fileName);
            for (int i = 1; i < ca.count; i++) {
                NSString *line = allTrim(ca[i]);
                NSString *resultLine = @"";
                if ([line hasPrefix:@"@protocol"] && ![line hasSuffix:@";"]) {
                    // Save the last one if exists
                    if (snippetLines.count > 0 && [protocolName isEqualToString:@""]) {
                        NSString *snippetName = [fileName stringByDeletingPathExtension];
                        NSString *content = [snippetLines componentsJoinedByString:@"\n"];
                        saveSnippet(snippetName, protocolName, content);
                    }
                    
                    
                    
                    isProtocol = YES;
                    isRequired = NO;
                    isOptional = NO;
                    hasProtocol = YES;
                    protocolName = [line substringFromIndex:10];
                    NSInteger pos = [protocolName rangeOfString:@"<"].location;
                    if (pos != NSNotFound) {
                        protocolName = [protocolName substringToIndex:pos];
                    }
                    resultLine = [@"#pragma mark - PROTOCOL " stringByAppendingString:protocolName];
                } else if (!isProtocol) {
                    // do nothing
                } else if ([line hasPrefix:@"@end"]) {
                    isProtocol = NO;
                } else if ([line hasPrefix:@"@optional"]) {
                    isOptional = YES;
                    isRequired = NO;
                    
                    resultLine = [@"#pragma mark - OPTIONAL methods for protocol " stringByAppendingString:protocolName];
                } else if ([line hasPrefix:@"@required"]) {
                    isRequired = YES;
                    isOptional = NO;
                    resultLine = [@"#pragma mark - REQUIRED methods for protocol " stringByAppendingString:protocolName];
                } else if ([line hasPrefix:@"//"]) {
                    resultLine = line;
                } else if ([line length] == 0) {
                    resultLine = line;
                } else {
                    resultLine = [line stringByReplacingOccurrencesOfString:@";" withString:@"{ }"];
                    resultLine = [NSString stringWithFormat:@"// %@", resultLine];
                }
                
                if (isProtocol) {
                    [snippetLines addObject:resultLine];
                    //                    NSLog(@"#!%@",  resultLine);
                } else {
                    //                    NSLog(@"%3d --- %@", i, line);
                }
            }
            
            if (hasProtocol) {
                NSString *snippetName = [fileName stringByDeletingPathExtension];
                NSString *content = [snippetLines componentsJoinedByString:@"\n"];
                saveSnippet(snippetName, protocolName, content);
            }
        }
    }
    printf(" done\n");
    printf("\nJust re-open Xcode and you find the snippets in the snippet container. Or start typing DELE (caps!!!) in code\n");
    
    return 0;
}


DELE