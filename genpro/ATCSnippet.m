//
//  ATCSnippet.m
//
//  Copyright (c) 2013 Delisa Mason. http://delisa.me
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#import "ATCSnippet.h"

@implementation ATCSnippet

- (id)initWithPlistURL:(NSURL *)plistURL {
    self = [super init];
    if (self) {
        self.fileURL = plistURL;
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistURL.path];
        [self updatePropertiesFromDictionary:plist];
    }
    return self;
}

- (void)updatePropertiesFromDictionary:(NSDictionary *)plist {
    self.title    = plist[@"IDECodeSnippetTitle"];
    self.uuid     = plist[@"IDECodeSnippetIdentifier"];
    self.platform = plist[@"IDECodeSnippetPlatform"];
    if (!self.platform) self.platform = @"All";
    self.language = [((NSString *)plist[@"IDECodeSnippetLanguage"]) stringByReplacingOccurrencesOfString:@"Xcode.SourceCodeLanguage." withString:@""];
    self.summary  = plist[@"IDECodeSnippetSummary"];
    self.contents = plist[@"IDECodeSnippetContents"];
    self.shortcut = plist[@"IDECodeSnippetCompletionPrefix"];
    self.scopes   = plist[@"IDECodeSnippetCompletionScopes"];
}

- (BOOL)persistChanges {
    if ([self validate]) {
        
        NSDictionary *content = self.propertyList;
        NSString *path = self.fileURL.path;
        BOOL result = [content writeToFile:path atomically:YES];
        return result;
        
        //
        //
        //
        //        NSFileManager *fm = [NSFileManager defaultManager];
        //        if (![fm fileExistsAtPath:self.fileURL.path])
        //            [fm createFileAtPath:self.fileURL.path contents:nil attributes:nil];
        //
        //
        //
        //
        //
        //        NSLog(@"dskfjhsdfkjsdhf: %@", self.propertyList);
        //        NSLog(@"PATH: %@", self.fileURL.path);
        //
        //        [self.propertyList writeToURL:self.fileURL atomically:YES];
        //        return [[self propertyList] writeToFile:@"/user/Cephei/desktop/xxx.plist" atomically:YES];
        //        return [[self propertyList] writeToFile:self.fileURL.path atomically:YES];
    }
    NSLog(@"XXXXXXXX");
    return NO;
}

- (BOOL)validate {
    return self.uuid && self.shortcut && self.contents;
}

- (NSDictionary *)propertyList {
    NSMutableDictionary *properties = @{
                                        @"IDECodeSnippetTitle": self.title ? : @"",
                                        @"IDECodeSnippetIdentifier": self.uuid ? : @"",
                                        @"IDECodeSnippetPlatform": self.platform ? : @"",
                                        @"IDECodeSnippetLanguage": [NSString stringWithFormat:@"Xcode.SourceCodeLanguage.%@", self.language],
                                        @"IDECodeSnippetSummary": self.summary ? : @"",
                                        @"IDECodeSnippetContents": self.contents ? : @"",
                                        @"IDECodeSnippetCompletionPrefix": self.shortcut ? : @"",
                                        @"IDECodeSnippetCompletionScopes": self.scopes ? : @[],
                                        @"IDECodeSnippetUserSnippet": @YES,
                                        @"IDECodeSnippetVersion": @2
                                        }.mutableCopy;
    
    if (self.platform && ![self.platform isEqual:@"All"]) {
        properties[@"IDECodeSnippetPlatform"] = self.platform;
    }
    
    return properties;
}

+ (NSSet *)keyPathsForValuesAffectingUuid {
    return [NSSet setWithObjects:@"title",@"platform",@"language",@"summary",@"contents",@"shortcut", nil];
}

@end
