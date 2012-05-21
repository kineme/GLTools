/*
 *  GLViewport.h
 *  GLTools
 *
 *  Created by Christopher Wright on 9/17/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */



@interface KinemeGLViewportPatch : QCPatch
{
	QCIndexPort	*inputX;
	QCIndexPort	*inputY;
	QCIndexPort	*inputW;
	QCIndexPort	*inputH;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end