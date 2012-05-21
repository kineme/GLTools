/*
 *  KinemeGLPolygonOffsetPatch.h
 *  GLTools
 *
 *  Created by Christopher Wright on 10/20/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */



@interface KinemeGLPolygonOffsetPatch : QCPatch
{
	QCNumberPort	*inputFactor;
	QCNumberPort	*inputUnits;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end