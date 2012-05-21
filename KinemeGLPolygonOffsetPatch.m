/*
 *  KinemeGLPolygonOffsetPatch.m
 *  GLTools
 *
 *  Created by Christopher Wright on 10/20/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */
#import <OpenGL/CGLMacro.h>
#import "KinemeGLPolygonOffsetPatch.h"

@implementation KinemeGLPolygonOffsetPatch : QCPatch

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
		[[self userInfo] setObject:@"Kineme GL Polygon Offset" forKey:@"name"];
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	glPolygonOffset([inputFactor doubleValue], [inputUnits doubleValue]);
	glEnable(GL_POLYGON_OFFSET_FILL);
	glEnable(GL_POLYGON_OFFSET_LINE);
	glEnable(GL_POLYGON_OFFSET_POINT);
	[self executeSubpatches: time arguments: arguments];
	glDisable(GL_POLYGON_OFFSET_FILL);
	glDisable(GL_POLYGON_OFFSET_LINE);
	glDisable(GL_POLYGON_OFFSET_POINT);
	glPolygonOffset(0.f, 0.f);

	return YES;
}

@end
