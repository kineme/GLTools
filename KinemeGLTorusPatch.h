/*
 *  KinemeGLTorusPatch.h
 *  GLTools
 *
 *  Created by Christopher Wright on 10/8/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */



@interface KinemeGLTorusPatch : QCPatch
{
	QCNumberPort	*inputMajorRadius;
	QCNumberPort	*inputMinorRadius;
	
	QCNumberPort	*inputXPosition;
	QCNumberPort	*inputYPosition;
	QCNumberPort	*inputZPosition;
	
	QCNumberPort	*inputXRotation;
	QCNumberPort	*inputYRotation;
	QCNumberPort	*inputZRotation;

	QCIndexPort		*inputSlices;
	QCIndexPort		*inputStacks;
	
	QCOpenGLPort_Image	*inputImage;
	QCOpenGLPort_Color	*inputColor;
	QCOpenGLPort_Blending	*inputBlending;
	QCOpenGLPort_Culling	*inputCulling;
	QCOpenGLPort_ZBuffer	*inputDepth;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end