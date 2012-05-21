/*
 *  GLScalePatch.m
 *  GLTools
 *
 *  Created by Christopher Wright on 9/5/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>
#import "KinemeGLScalePatch.h"

@implementation KinemeGLScalePatch : QCPatch

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
		[inputX setDoubleValue: 1.0];
		[inputY setDoubleValue: 1.0];
		[inputZ setDoubleValue: 1.0];
		[[self userInfo] setObject:@"Kineme GL Scale" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	double x = [inputX doubleValue], y = [inputY doubleValue], z = [inputZ doubleValue];
	CGLContextObj cgl_ctx = [context CGLContextObj];

	glPushMatrix();
	glScaled(x, y, z);
	if([inputFixLighting booleanValue])
		glEnable(GL_NORMALIZE); 
	[self executeSubpatches:time arguments:arguments];
	glPopMatrix();
	
	return YES;
}

@end
