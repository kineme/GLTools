/*
 *  KinemeGLLineExpressionPatch.h
 *  GLTools
 *
 *  Created by Christopher Wright on 1/18/09.
 *  Copyright (c) 2009 Kosada Incorporated. All rights reserved.
 *
 */



@interface KinemeGLLineExpressionPatch : QCPatch
{
	QCStringPort	*inputXExpression;
	QCStringPort	*inputYExpression;
	QCStringPort	*inputZExpression;
	QCIndexPort		*inputSteps;
	QCNumberPort	*inputWidth;
	
	QCIndexPort		*inputPattern;
	QCIndexPort		*inputRepeatCount;
	
	QCStringPort	*inputRExpression;
	QCStringPort	*inputGExpression;
	QCStringPort	*inputBExpression;
	QCStringPort	*inputAExpression;
	
	QCNumberPort	*inputXPosition;
	QCNumberPort	*inputYPosition;
	QCNumberPort	*inputZPosition;
	QCNumberPort	*inputXRotation;
	QCNumberPort	*inputYRotation;
	QCNumberPort	*inputZRotation;
	
	QCStructurePort	*inputAdditionalVariables;
	
	QCOpenGLPort_Blending *inputBlending;
	QCOpenGLPort_ZBuffer *inputDepth;
	
	id xExpression;
	id yExpression;
	id zExpression;
	id rExpression;
	id gExpression;
	id bExpression;
	id aExpression;
}

- (id)initWithIdentifier:(id)fp8;

//- (BOOL)setup:(QCOpenGLContext *)context;
- (void)cleanup:(QCOpenGLContext *)context;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end