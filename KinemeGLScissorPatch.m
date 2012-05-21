/*
 *  KinemeGLScissor.m
 *  GLTools
 *
 *  Created by Christopher Wright on 1/20/09.
 *  Copyright (c) 2009 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>
#import "KinemeGLScissorPatch.h"
//#import "KinemeGLScissorUI.h"


@implementation KinemeGLScissorPatch : QCPatch

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
		[inputWidth setIndexValue: 320];
		[inputHeight setIndexValue: 240];
		[[self userInfo] setObject:@"Kineme GL Scissor" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLboolean isEnabled;
	GLint	oldScissor[4];
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	isEnabled = glIsEnabled(GL_SCISSOR_TEST);
	if(isEnabled)
		glGetIntegerv(GL_SCISSOR_BOX, oldScissor);
	else
		glEnable(GL_SCISSOR_TEST);
	glScissor([inputX indexValue], [inputY indexValue], [inputWidth indexValue], [inputHeight indexValue]);
	
	[self executeSubpatches: time arguments: arguments];
	
	if(!isEnabled)
		glDisable(GL_SCISSOR_TEST);
	else //restore previous scissor region
		glScissor(oldScissor[0], oldScissor[1], oldScissor[2], oldScissor[3]);

	return YES;
}

@end
