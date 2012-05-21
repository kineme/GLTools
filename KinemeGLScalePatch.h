/*
 *  GLScalePatch.h
 *  GLTools
 *
 *  Created by Christopher Wright on 9/5/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */



@interface KinemeGLScalePatch : QCPatch
{
	QCNumberPort *inputX;
	QCNumberPort *inputY;
	QCNumberPort *inputZ;
	QCBooleanPort *inputFixLighting;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end