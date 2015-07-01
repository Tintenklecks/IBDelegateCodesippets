//
//  ExtendNSLogFunctionality.h
//  ExtendNSLog

#import <Foundation/Foundation.h>

#define EXTENDEDNSLOGVERSION @"1.0 beta"

#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define NSLog(x...)
#endif


#define NSLOG_ALL       0xFFFF

#define NSLOG_NOTHING   0x0000
#define NSLOG_DEFAULT   (1 << 0)
#define NSLOG_USER1     (1 << 1)
#define NSLOG_USER2     (1 << 2)
#define NSLOG_USER3     (1 << 3)
#define NSLOG_USER4     (1 << 4)
#define NSLOG_USER5     (1 << 5)
#define NSLOG_USER6     (1 << 6)

#define NSLOG_ERROR     (1 << 7)
#define NSLOG_WARNING   (1 << 8)
#define NSLOG_INFO      (1 << 9)




/*
 COMMANDS:
 
 All commands begin with a #, i.e.
    NSLog(@"#COLOR:%@", NSLOG_USER1_COLOR);  // Set User color for normal output in USER1_COLOR
 or
    NSLog(@"#!Print this line in the %@", @"error color");

 COLOR COMMANDS:
 
 #! - this single Output is displayed in the error color
 #? - this single Output is displayed in the warning color
 #. - this single Output is displayed in the info color
 #0 - this single Output is displayed in the default color
 #1 ... #6 this single Output is displayed in the NSLOG_USER_1 (..6) color

 
 Display commands:

 #SHOWFILENAME       displays the .m filename before the output
 #SHOWFUNCTIONNAME   displays the methodname before the output
 #SHOWLINENUMBER     displays the line number before the output
 #HIDEFILENAME       hides the .m filename before the output
 #HIDEFUNCTIONNAME   hides the methodname before the output
 #HIDELINENUMBER     hides the line number before the output
 
 #-    this displays (only) the current line without extra info 
 NSLog(@"#-"); for a new line

 
 #DISPLAYONLY xx   -   display only NSLog commands that match the state xx, i.e.
 NSLog(@"#DISPLAYONLY %d", NSLOG_WARNING + NSLOG_USER1);
 
 #COLOR xx   -   set the default display color  xx, i.e.
 NSLog(@"#COLOR %d", NSLOG_USER4);
 
 
*/


void ExtendNSLog(const char *file, int lineNumber, const char *methodName, NSString *format, ...);




