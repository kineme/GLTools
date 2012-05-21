/*
 *  GLLoadMatrix.m
 *  GLTools
 *
 *  Created by Christopher Wright on 9/2/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import "KinemeGLLoadMatrixPatch.h"
#import <OpenGL/CGLMacro.h>


@implementation KinemeGLLoadMatrixPatch : QCPatch

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
		[inputMatrix setMaxIndexValue: 1];
		[input00 setDoubleValue: 1.0];
		[input11 setDoubleValue: 1.0];
		[input22 setDoubleValue: 1.0];
		[input33 setDoubleValue: 1.0];
		[[self userInfo] setObject:@"Kineme GL Load Matrix" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	double m[16] =
	{
		[input00 doubleValue],
		[input01 doubleValue],
		[input02 doubleValue],
		[input03 doubleValue],
		
		[input10 doubleValue],
		[input11 doubleValue],
		[input12 doubleValue],
		[input13 doubleValue],
		
		[input20 doubleValue],
		[input21 doubleValue],
		[input22 doubleValue],
		[input23 doubleValue],
		
		[input30 doubleValue],
		[input31 doubleValue],
		[input32 doubleValue],
		[input33 doubleValue],
	};
	
	double o[16];
	
	if([inputMatrix indexValue])
	{
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
	}
	else
	{
		// can't push/pop projection matrix without stack underflows...
		glGetDoublev(GL_PROJECTION_MATRIX, o);
		glMatrixMode(GL_PROJECTION);
	}
	
	if([inputTranspose booleanValue])
		glLoadTransposeMatrixd(m);
	else
		glLoadMatrixd(m);
	
	[self executeSubpatches:time arguments:arguments];
	
	if([inputMatrix indexValue])
		glPopMatrix();
	else
		glLoadMatrixd(o);
	
	return YES;
}

@end
