/*
 *  GLColorMask.h
 *  GLTools
 *
 *  Created by Christopher Wright on 9/2/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */



@interface KinemeGLColorMaskPatch : QCPatch
{
	QCBooleanPort *inputRed;
	QCBooleanPort *inputGreen;
	QCBooleanPort *inputBlue;
	QCBooleanPort *inputAlpha;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end