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
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        // insert code here...
        
        NSString *xcodePath = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/UIKit.framework/Headers";
        
        
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
    return 0;
}

#pragma mark - PROTOCOL UITableViewDelegate

#pragma mark - OPTIONAL methods for protocol UITableViewDelegate

// Display customization

// - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{ }
// - (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0){ }
// - (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0){ }
// - (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0){ }
// - (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0){ }
// - (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0){ }

// Variable height support

// - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ }
// - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{ }
// - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{ }

// Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
// If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
// - (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0){ }
// - (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0){ }
// - (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0){ }

// Section header & footer information. Views are preferred over title should you decide to provide both

// - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{ }   // custom view for header. will be adjusted to default or specified header height
// - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{ }   // custom view for footer. will be adjusted to default or specified footer height

// Accessories (disclosures).

// - (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0){ }
// - (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{ }

// Selection

// -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
// - (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0){ }
// - (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0){ }
// - (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0){ }

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
// - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{ }
// - (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0){ }
// Called after the user changes the selection.
// - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ }
// - (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0){ }

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
// - (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{ }
// - (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0){ }
// - (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0){ } // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
// - (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{ }

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
// - (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{ }
// - (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{ }

// Moving/reordering

// Allows customization of the target row for a particular row as it is being moved/reordered
// - (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{ }

// Indentation

// - (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{ } // return 'depth' of row for hierarchies

// Copy/Paste.  All three methods must be implemented by the delegate.

// - (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0){ }
// - (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender NS_AVAILABLE_IOS(5_0){ }
// - (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender NS_AVAILABLE_IOS(5_0){ }

#pragma mark - PROTOCOL UITableViewDataSource

#pragma mark - REQUIRED methods for protocol UITableViewDataSource

// - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ }

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

// - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{ }

#pragma mark - OPTIONAL methods for protocol UITableViewDataSource

// - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{ }              // Default is 1 if not implemented

// - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{ }    // fixed font style. use custom view (UILabel) if you want something different
// - (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{ }

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
// - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{ }

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
// - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{ }

// Index

// - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{ }                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
// - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{ }  // tell table which section corresponds to section title/index (e.g. "B",1))

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
// - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{ }

// Data manipulation - reorder / moving support

// - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{ }
