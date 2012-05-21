/*
 *  KinemeGLScissor.h
 *  GLTools
 *
 *  Created by Christopher Wright on 1/20/09.
 *  Copyright (c) 2009 Kosada Incorporated. All rights reserved.
 *
 */

@interface KinemeGLScissorPatch : QCPatch
{
	QCIndexPort	*inputX;
	QCIndexPort	*inputY;
	QCIndexPort *inputWidth;
	QCIndexPort *inputHeight;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end