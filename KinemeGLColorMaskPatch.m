/*
 *  GLColorMask.m
 *  GLTools
 *
 *  Created by Christopher Wright on 9/2/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import "KinemeGLColorMaskPatch.h"
#import <OpenGL/CGLMacro.h>

@implementation KinemeGLColorMaskPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return YES;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
		[inputRed setBooleanValue: YES];
		[inputGreen setBooleanValue: YES];
		[inputBlue setBooleanValue: YES];
		[inputAlpha setBooleanValue: YES];
		[[self userInfo] setObject:@"Kineme GL Color Mask" forKey:@"name"];
	}

	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];

	GLboolean mask[4];
	glGetBooleanv(GL_COLOR_WRITEMASK, mask);
	
	glColorMask([inputRed booleanValue],
				[inputGreen booleanValue],
				[inputBlue booleanValue],
				[inputAlpha booleanValue]);
	[self executeSubpatches:time arguments:arguments];
	glColorMask(mask[0], mask[1], mask[2], mask[3]);

	return YES;
}

@end
