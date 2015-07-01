//
//  ExtendNSLogFunctionality.m
//  ExtendNSLog

#import "ExtendNSLog.h"



#define NSLOG_DEFAULT_COLOR     "\033[fg200,200,200;\033[bg10,10,10;"  // Colors for the plugin XCodeColors
#define NSLOG_ERROR_COLOR       "\033[fg255,0,0;\033[bg255,255,255;"
#define NSLOG_WARNING_COLOR     "\033[fg255,128,128;\033[bg10,10,10;"
#define NSLOG_INFO_COLOR        "\033[fg200,200,200;\033[bg10,10,10;"
#define NSLOG_USER1_COLOR       "\033[fg0,0,255;\033[bg10,10,10;"   // Blue
#define NSLOG_USER2_COLOR       "\033[fg0,255,255;\033[bg10,10,10;"
#define NSLOG_USER3_COLOR       "\033[fg0,255,0;\033[bg10,10,10;"
#define NSLOG_USER4_COLOR       "\033[fg128,0,128;\033[bg10,10,10;"
#define NSLOG_USER5_COLOR       "\033[fg255,0,255;\033[bg10,10,10;"
#define NSLOG_USER6_COLOR       "\033[fg128,128,255;\033[bg10,10,10;"

void NSLogTest(void);
NSString *colorString(NSString *foreground, NSString *background);




NSString *colorString(NSString *foreground, NSString *background) {
	static unsigned int fgColor;
	static unsigned int bgColor;
    
	if (bgColor == fgColor) bgColor = fgColor > 0x8FFFFF ? 0 : 0xFFFFFF;
    
    
	if (foreground) [[NSScanner scannerWithString:foreground] scanHexInt:&fgColor];
	if (background) [[NSScanner scannerWithString:background] scanHexInt:&bgColor];
    
    
	int fgRed, fgGreen, fgBlue;
	int bgRed, bgGreen, bgBlue;
    
	fgRed = fgColor & 0xFF;
	bgRed = bgColor & 0xFF;
    
	fgGreen = (fgColor >> 8) & 0xFF;
	bgGreen = (bgColor >> 8) & 0xFF;
    
	fgBlue = (fgColor >> 16) & 0xFF;
	bgBlue = (bgColor >> 16) & 0xFF;
    
    
    
	return [NSString stringWithFormat:@"\033[fg%d,%d,%d;\033[bg%d,%d,%d;", fgRed, fgGreen, fgBlue, bgRed, bgGreen, bgBlue];
}

int getCommandValue(NSString *line, NSString *command, int defaultValue);

int getCommandValue(NSString *line, NSString *command, int defaultValue) {
	NSString *defaultColorString = [line substringFromIndex:[command rangeOfString:command].length];
	if ([defaultColorString characterAtIndex:0] == ':') {
		defaultColorString = [[defaultColorString substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	if ([defaultColorString intValue]) {
		return [defaultColorString intValue];
	}
    
	return defaultValue;
}

NSString *getCommandString(NSString *line, NSString *command, NSString *defaultValue);

NSString *getCommandString(NSString *line, NSString *command, NSString *defaultValue) {
	NSString *defaultCommandValue = [line substringFromIndex:[command rangeOfString:command].length];
	if ([defaultCommandValue characterAtIndex:0] == ':') {
		defaultCommandValue = [[defaultCommandValue substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		return defaultCommandValue;
	}
    
	return defaultValue;
}

void saveToFile(void);

void saveToFile(void) {
	NSString *errorFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"console.log"];
	freopen([errorFile UTF8String], "a+", stderr);
}

void ExtendNSLog(const char *file, int lineNumber, const char *methodName, NSString *format, ...) {
	static BOOL logToConsole = NO;
	static BOOL initialized = NO;
	static BOOL displayFilename = YES;
	static BOOL displayLineNumber = YES;
	static BOOL displayMethodName = YES;
	static BOOL displayClassName = NO;
    
	static int mode = NSLOG_ALL;
	static int defaultColorMode = NSLOG_DEFAULT;
	int currentMode = NSLOG_DEFAULT;
	BOOL suppressInfo = NO;
    
    
	if (!initialized) {
		if (!isatty(STDERR_FILENO)) { // If no display attached (or the file logging is explicitely initiated) the redirect the logging to a file
			saveToFile();
			logToConsole = NO;
		}
		else {
			logToConsole = YES;
		}
		initialized = YES;
	}
    
	// Type to hold information about variable arguments.
	va_list ap;
    
	// Initialize a variable argument list.
	va_start(ap, format);
    
	// NSLog only adds a newline to the end of the NSLog format if
	// one is not already there.
	// Here we are utilizing this feature of NSLog()
	if (![format hasSuffix:@"\n"]) {
		format = [format stringByAppendingString:@"\n"];
	}
    
	NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
	// End using variable argument list.
	va_end(ap);
    
	NSString *cleanBody = [[body uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    
	if (cleanBody.length>0 && [cleanBody characterAtIndex:0] == '#') {  // SETTING/COMMAND
		cleanBody = [cleanBody substringFromIndex:1];
        
		int substringIndex = 2;
		// Single line state / color commands
		switch ([cleanBody characterAtIndex:0]) {
			case '-': suppressInfo = YES;
                
			case '!': currentMode = NSLOG_ERROR; break;    //    #! = 1 line ERRORCOLOR
                
			case '?': currentMode = NSLOG_WARNING; break;  //    #? = 1 line WARNING ...
                
			case '.': currentMode = NSLOG_INFO; break;
                
			case '0': currentMode = NSLOG_DEFAULT; break;
                
			case '1': currentMode = NSLOG_USER1; break;
                
			case '2': currentMode = NSLOG_USER2; break;
                
			case '3': currentMode = NSLOG_USER3; break;
                
			case '4': currentMode = NSLOG_USER4; break;
                
			case '5': currentMode = NSLOG_USER5; break;
                
			case '6': currentMode = NSLOG_USER6; break;
                
			default:
				substringIndex = 0;
				break;
		}
		body = [body substringFromIndex:substringIndex];
        
        
		BOOL command = YES;
		if ([cleanBody isEqualToString:@"SHOWFILENAME"]) displayFilename = YES;
		else if ([cleanBody isEqualToString:@"SHOWFUNCTIONNAME"]) displayMethodName = YES;
		else if ([cleanBody isEqualToString:@"SHOWLINENUMBER"]) displayLineNumber = YES;
		else if ([cleanBody isEqualToString:@"HIDEFILENAME"]) displayFilename = NO;
		else if ([cleanBody isEqualToString:@"HIDEFUNCTIONNAME"]) displayMethodName = NO;
		else if ([cleanBody isEqualToString:@"HIDELINENUMBER"]) displayLineNumber = NO;
		else if ([cleanBody isEqualToString:@"LOGTOFILE"]) {
			logToConsole = NO;  saveToFile();
		}
		else if ([cleanBody isEqualToString:@"TEST"]) {
			NSLogTest();
		}
		else if ([cleanBody isEqualToString:@"CLEAR"]) {
			if (logToConsole) {
				for (int i = 0; i < 100; i++) fprintf(stderr, "\n"); // HAHA ... just joking, but it´s OK for me
			}
			else {
				NSString *errorFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"console.log"];
				[[NSFileManager defaultManager] removeItemAtPath:errorFile error:nil];
				freopen([errorFile UTF8String], "a+", stderr);
			}
		}
		else if ([cleanBody isEqualToString:@"TIMESTAMP"]) {
			body = [NSString stringWithFormat:@"%@\n", [NSDate date]]; command = NO;
		}
        
		else if ([cleanBody isEqualToString:@"NSLOGINFO"]) {
			body = [NSString stringWithFormat:
			        @"\n***\nAllowed modes: %X\nCurrent mode: %X \nDefault color mode: %X \nDisplay Filename: %@ \nDisplay Methodname: %@ \nDisplay line number: %@\n***\n\n",
			        mode, currentMode, defaultColorMode,
			        displayFilename ? @"YES"  :@"NO",
			        displayMethodName ? @"YES":@"NO",
			        displayLineNumber ? @"YES":@"NO"];
			fprintf(stderr, "%s", [body UTF8String]);
		}
		else if ([cleanBody rangeOfString:@"COLOR"].location == 0) {   // Set the default color
			defaultColorMode  = getCommandValue(cleanBody, @"COLOR", defaultColorMode);
			currentMode = defaultColorMode;
		}
		else if ([cleanBody rangeOfString:@"FOREGROUND"].location == 0) {   // Set the default color with HEX
			defaultColorMode = NSLOG_DEFAULT;
			NSString *color = getCommandString(cleanBody, @"FOREGROUND", @"FF8800");
			colorString(color, nil);
		}
		else if ([cleanBody rangeOfString:@"BACKGROUND"].location == 0) {   // Set the default color with HEX
			defaultColorMode = NSLOG_DEFAULT;
			NSString *color = getCommandString(cleanBody, @"BACKGROUND", @"444444");
			colorString(nil, color);
		}
		else if ([cleanBody rangeOfString:@"DISPLAYONLY"].location == 0) {   // Set what is displayed
			mode = getCommandValue(cleanBody, @"DISPLAYONLY", mode);
		}
		else command = NO;
        
        
		if (command) return;
	}
    
    
	if ((currentMode & mode) != currentMode)
		return; // wrong mode => no display
    
	// Set the color of
	switch (currentMode) {
		case NSLOG_ERROR : if (logToConsole) fprintf(stderr,  NSLOG_ERROR_COLOR); break;
            
		case NSLOG_WARNING : if (logToConsole) fprintf(stderr,  NSLOG_WARNING_COLOR); break;
            
		case NSLOG_INFO : if (logToConsole) fprintf(stderr,  NSLOG_INFO_COLOR); break;
            
		case NSLOG_USER1:   if (logToConsole) fprintf(stderr,  NSLOG_USER1_COLOR); break;
            
		case NSLOG_USER2:   if (logToConsole) fprintf(stderr,  NSLOG_USER2_COLOR); break;
            
		case NSLOG_USER3:   if (logToConsole) fprintf(stderr,  NSLOG_USER3_COLOR); break;
            
		case NSLOG_USER4:   if (logToConsole) fprintf(stderr,  NSLOG_USER4_COLOR); break;
            
		case NSLOG_USER5:   if (logToConsole) fprintf(stderr,  NSLOG_USER5_COLOR); break;
            
		case NSLOG_USER6:   if (logToConsole) fprintf(stderr,  NSLOG_USER6_COLOR); break;
            
		default:
            
			switch (defaultColorMode) {
				case NSLOG_ERROR:   if (logToConsole) fprintf(stderr,  NSLOG_ERROR_COLOR); break;
                    
				case NSLOG_WARNING: if (logToConsole) fprintf(stderr,  NSLOG_WARNING_COLOR); break;
                    
				case NSLOG_INFO: if (logToConsole) fprintf(stderr,  NSLOG_INFO_COLOR); break;
                    
				case NSLOG_USER1: if (logToConsole) fprintf(stderr,  NSLOG_USER1_COLOR); break;
                    
				case NSLOG_USER2: if (logToConsole) fprintf(stderr,  NSLOG_USER2_COLOR); break;
                    
				case NSLOG_USER3: if (logToConsole) fprintf(stderr,  NSLOG_USER3_COLOR); break;
                    
				case NSLOG_USER4: if (logToConsole) fprintf(stderr,  NSLOG_USER4_COLOR); break;
                    
				case NSLOG_USER5: if (logToConsole) fprintf(stderr,  NSLOG_USER5_COLOR); break;
                    
				case NSLOG_USER6: if (logToConsole) fprintf(stderr,  NSLOG_USER6_COLOR); break;
                    
				default:
					if (logToConsole) fprintf(stderr, "%s", [colorString(Nil, Nil) UTF8String]); break;
			}
            
			break;
	}
    
	if (!suppressInfo) {
		NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
		NSString *classAndMethod = [NSString stringWithUTF8String:methodName];
		if (!displayClassName) {
			int blankPosition = (int)[classAndMethod rangeOfString:@" "].location;
			classAndMethod = [classAndMethod substringFromIndex:blankPosition + 1];
			NSUInteger bracket = [classAndMethod rangeOfString:@"]"].location;
			if (bracket != NSNotFound) {
				classAndMethod = [classAndMethod substringToIndex:bracket];
			}
		}
		if (displayFilename) fprintf(stderr, "%s ", [fileName UTF8String]);
		if (displayLineNumber && displayMethodName) {
			if (displayClassName) {
				fprintf(stderr, "(%s:%d) ", [classAndMethod UTF8String], lineNumber);
			}
			else {
				fprintf(stderr, "[%s:%d] ", [classAndMethod UTF8String], lineNumber);
			}
		}
		else if (displayLineNumber) fprintf(stderr, "[%d] ", lineNumber);
		else if (displayMethodName) fprintf(stderr, "%s ", [classAndMethod UTF8String]);
	}
	fprintf(stderr, "%s", [body UTF8String]);
    
	if (logToConsole) fprintf(stderr, "\033[;");       // Clear any foreground or background color
}

void NSLogTest(void) {   // Just a sample void to clarify
	NSLog(@"#HidEFILENAME");
	NSLog(@"#1Extended NSLog  Version %@", EXTENDEDNSLOGVERSION);
    
	NSLog(@"#!This is an error");
	NSLog(@"#?This is a warning");
	NSLog(@"#.This is an info line");
	NSLog(@"#1This is User Color 1");
	NSLog(@"#2This is User Color 2");
	NSLog(@"#3This is User Color 3");
	NSLog(@"#4This is User Color 4");
	NSLog(@"#5This is User Color 5");
	NSLog(@"#6This is User Color 6");
	NSLog(@"#0This is the default color ");
    
	NSLog(@"Just a normal string without formatting");
	NSLog(@"Just another normal string without formatting");
	NSLog(@"And another string without formatting");
	NSLog(@"#DISPLAYONLY: %d", NSLOG_ERROR | NSLOG_DEFAULT);
    
	NSLog(@"And starting from now only ERROR and DEFAULT NSLogs are displayed");
    
	NSLog(@"#!This is an error");
	NSLog(@"#?This is a warning");
	NSLog(@"#.This is an info line");
	NSLog(@"#1This is User Color 1");
    
    
	NSLog(@"#-"); /// just an empty line
    
    
	NSLog(@"#FOREGROUND: %@", @"00EEEE");
	NSLog(@"#BACKGROUND: %@", @"222222");
    
	NSLog(@"From now on, normal NSLOGs will be displayed in this color");
	NSLog(@"Haha ... this one as well");
	NSLog(@"... and this one");
}
