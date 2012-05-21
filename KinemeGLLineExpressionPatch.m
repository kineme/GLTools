/*
 *  KinemeGLLineExpressionPatch.m
 *  GLTools
 *
 *  Created by Christopher Wright on 1/18/09.
 *  Copyright (c) 2009 Kosada Incorporated. All rights reserved.
 *
 */

#import "KinemeGLLineExpressionPatch.h"
//#import "KinemeGLLineExpressionPatchUI.h"
#import <OpenGL/CGLMacro.h>

static Class QCMathematicalExpressionClass = nil;

@interface NSObject (GLToolsWarningSuppression)
-(id)initWithString:(NSString*)exp error:(NSString**)err;
-(double)evaluate;
-(NSArray*)variables;
@end

@implementation KinemeGLLineExpressionPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

+ (QCPatchTimeMode)timeModeWithIdentifier:(id)fp8
{
	return kQCPatchTimeModeTimeBase;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(QCMathematicalExpressionClass == nil)
		QCMathematicalExpressionClass = objc_getClass("QCMathematicalExpression");
	if(self=[super initWithIdentifier:fp8])
	{
		// give a rad high-res spring by default
		[inputSteps setIndexValue: 1000];
		[inputXExpression setStringValue: @"0.25*sin(5760*t)"];
		[inputYExpression setStringValue: @"t-0.5"];
		[inputZExpression setStringValue: @"0.25*cos(5760*t)"];
		[inputRExpression setStringValue: @"t"];
		[inputGExpression setStringValue: @"1-t"];
		[inputBExpression setStringValue: @"1+sin(t*2160)"];
		[inputAExpression setStringValue: @"1"];
		[inputPattern setIndexValue: 0xffff];
		[inputWidth setDoubleValue: 1.0];
		[inputWidth setMinDoubleValue: 0.5];
		[[self userInfo] setObject:@"Kineme GL Line Expression" forKey:@"name"];
	}
	
	return self;
}

- (void)cleanup:(QCOpenGLContext *)context
{
	[xExpression release];
	[yExpression release];
	[zExpression release];
	[rExpression release];
	[gExpression release];
	[bExpression release];
	[aExpression release];
	
	xExpression = nil;
	yExpression = nil;
	zExpression = nil;
	rExpression = nil;
	gExpression = nil;
	bExpression = nil;
	aExpression = nil;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	NSString *error = nil;

	if(xExpression == nil || [inputXExpression wasUpdated] && [[inputXExpression stringValue] length] > 0)
	{
		[xExpression release];
		xExpression = [[QCMathematicalExpressionClass allocWithZone:NULL] initWithString: [inputXExpression stringValue] error: &error ];
		if(error)
		{
			NSLog(@"parse error: %x", error);
			return NO;
		}
	}
	if(yExpression == nil || [inputYExpression wasUpdated] && [[inputYExpression stringValue] length] > 0)
	{
		[yExpression release];
		yExpression = [[QCMathematicalExpressionClass allocWithZone:NULL] initWithString: [inputYExpression stringValue] error: &error ];
		if(error)
		{
			NSLog(@"parse error: %x", error);
			[xExpression release];
			xExpression = nil;
			return NO;
		}
	}
	if(zExpression == nil || [inputZExpression wasUpdated] && [[inputZExpression stringValue] length] > 0)
	{
		[zExpression release];
		zExpression = [[QCMathematicalExpressionClass allocWithZone:NULL] initWithString: [inputZExpression stringValue] error: &error ];
		if(error)
		{
			NSLog(@"parse error: %x", error);
			[xExpression release];
			xExpression = nil;
			[yExpression release];
			yExpression = nil;
			return NO;
		}
	}

	if(rExpression == nil || [inputRExpression wasUpdated] && [[inputRExpression stringValue] length] > 0)
	{
		[rExpression release];
		rExpression = [[QCMathematicalExpressionClass allocWithZone:NULL] initWithString: [inputRExpression stringValue] error: &error ];
		if(error)
		{
			NSLog(@"parse error: %x", error);
			[xExpression release];
			xExpression = nil;
			[yExpression release];
			yExpression = nil;
			[zExpression release];
			zExpression = nil;
			return NO;
		}
	}
	if(gExpression == nil || [inputGExpression wasUpdated] && [[inputGExpression stringValue] length] > 0)
	{
		[gExpression release];
		gExpression = [[QCMathematicalExpressionClass allocWithZone:NULL] initWithString: [inputGExpression stringValue] error: &error ];
		if(error)
		{
			NSLog(@"parse error: %x", error);
			[xExpression release];
			xExpression = nil;
			[yExpression release];
			yExpression = nil;
			[zExpression release];
			zExpression = nil;
			[rExpression release];
			rExpression = nil;
			return NO;
		}
	}
	if(bExpression == nil || [inputBExpression wasUpdated] && [[inputBExpression stringValue] length] > 0)
	{
		[bExpression release];
		bExpression = [[QCMathematicalExpressionClass allocWithZone:NULL] initWithString: [inputBExpression stringValue] error: &error ];
		if(error)
		{
			NSLog(@"parse error: %x", error);
			[xExpression release];
			xExpression = nil;
			[yExpression release];
			yExpression = nil;
			[zExpression release];
			zExpression = nil;
			[rExpression release];
			rExpression = nil;
			[gExpression release];
			gExpression = nil;
			return NO;
		}
	}
	if(aExpression == nil || [inputAExpression wasUpdated] && [[inputAExpression stringValue] length] > 0)
	{
		[aExpression release];
		aExpression = [[QCMathematicalExpressionClass allocWithZone:NULL] initWithString: [inputAExpression stringValue] error: &error ];
		if(error)
		{
			NSLog(@"parse error: %x", error);
			[xExpression release];
			xExpression = nil;
			[yExpression release];
			yExpression = nil;
			[zExpression release];
			zExpression = nil;
			[rExpression release];
			rExpression = nil;
			[gExpression release];
			gExpression = nil;
			[bExpression release];
			bExpression = nil;
			return NO;
		}
	}
	
	//if(xExpression == nil || yExpression ==nil || zExpression == nil)
	//	return YES;
		
	unsigned int i, steps = [inputSteps indexValue];
	double rSteps = 1.0/(steps-1);	
		
	NSDictionary *vars = [[inputAdditionalVariables structureValue] dictionaryRepresentation];
	IMP objectForKey = [vars methodForSelector:@selector(objectForKey:)];
	for(id key in vars)
	{
		//id obj = [vars objectForKey: key];
		id obj = objectForKey(vars, @selector(objectForKey:), key);
		if([obj respondsToSelector: @selector(doubleValue)])
		{
			NSUInteger index = [[xExpression variables] indexOfObject: key];
			if(index != NSNotFound)
				[xExpression setVariable: [[vars objectForKey:key] doubleValue] atIndex: index];
			index = [[yExpression variables] indexOfObject: key];
			if(index != NSNotFound)
				[yExpression setVariable: [[vars objectForKey:key] doubleValue] atIndex: index];
			index = [[zExpression variables] indexOfObject: key];
			if(index != NSNotFound)
				[zExpression setVariable: [[vars objectForKey:key] doubleValue] atIndex: index];
			index = [[rExpression variables] indexOfObject: key];
			if(index != NSNotFound)
				[rExpression setVariable: [[vars objectForKey:key] doubleValue] atIndex: index];
			index = [[gExpression variables] indexOfObject: key];
			if(index != NSNotFound)
				[gExpression setVariable: [[vars objectForKey:key] doubleValue] atIndex: index];
			index = [[bExpression variables] indexOfObject: key];
			if(index != NSNotFound)
				[bExpression setVariable: [[vars objectForKey:key] doubleValue] atIndex: index];
			index = [[aExpression variables] indexOfObject: key];
			if(index != NSNotFound)
				[aExpression setVariable: [[vars objectForKey:key] doubleValue] atIndex: index];
		}
	}
	
	NSUInteger txIndex = [[xExpression variables] indexOfObject: @"time"];
	NSUInteger tyIndex = [[yExpression variables] indexOfObject: @"time"];
	NSUInteger tzIndex = [[zExpression variables] indexOfObject: @"time"];
	NSUInteger trIndex = [[rExpression variables] indexOfObject: @"time"];
	NSUInteger tgIndex = [[gExpression variables] indexOfObject: @"time"];
	NSUInteger tbIndex = [[bExpression variables] indexOfObject: @"time"];
	NSUInteger taIndex = [[aExpression variables] indexOfObject: @"time"];
	if(txIndex != NSNotFound)
		[xExpression setVariable: time atIndex: txIndex];
	if(tyIndex != NSNotFound)
		[yExpression setVariable: time atIndex: tyIndex];
	if(tzIndex != NSNotFound)
		[zExpression setVariable: time atIndex: tzIndex];
	if(trIndex != NSNotFound)
		[rExpression setVariable: time atIndex: trIndex];
	if(tgIndex != NSNotFound)
		[gExpression setVariable: time atIndex: tgIndex];
	if(tbIndex != NSNotFound)
		[bExpression setVariable: time atIndex: tbIndex];
	if(taIndex != NSNotFound)
		[aExpression setVariable: time atIndex: taIndex];
	txIndex = [[xExpression variables] indexOfObject: @"t"];
	tyIndex = [[yExpression variables] indexOfObject: @"t"];
	tzIndex = [[zExpression variables] indexOfObject: @"t"];
	trIndex = [[rExpression variables] indexOfObject: @"t"];
	tgIndex = [[gExpression variables] indexOfObject: @"t"];
	tbIndex = [[bExpression variables] indexOfObject: @"t"];
	taIndex = [[aExpression variables] indexOfObject: @"t"];
	
	//NSLog(@"vars:\n   * x%@\n   * y%@\n   * z%@\n   * r%@\n   * g%@\n   * b%@\n   * a%@\n\n", 
	//	  [xExpression variables],[yExpression variables],[zExpression variables],
	//	  [rExpression variables],[gExpression variables],[bExpression variables],[aExpression variables]);
	
	CGLContextObj cgl_ctx = [context CGLContextObj];

	GLint oldFactor, oldPattern;
	
	[inputBlending setOnOpenGLContext: context];
	[inputDepth setOnOpenGLContext: context];
	
	if([inputPattern indexValue] != 0xffff)
	{
		glGetIntegerv(GL_LINE_STIPPLE_REPEAT,&oldFactor);
		glGetIntegerv(GL_LINE_STIPPLE_PATTERN,&oldPattern);
		glEnable(GL_LINE_STIPPLE);
		glLineStipple([inputRepeatCount indexValue],[inputPattern indexValue]);
	}
	
	float oldWidth;
	glGetFloatv(GL_LINE_WIDTH, &oldWidth);
	glLineWidth([inputWidth doubleValue]);
	glNormal3b(0,0,0);
	glPushMatrix();

	CGFloat matrix[16];
	
	QCGLMakeTransformationMatrix(matrix,[inputXRotation doubleValue],[inputYRotation doubleValue],[inputZRotation doubleValue],
								 [inputXPosition doubleValue],[inputYPosition doubleValue],[inputZPosition doubleValue]);
	
	KIGLMultMatrix(matrix);
		
	/*glTranslated([inputXPosition doubleValue],
				 [inputYPosition doubleValue],
				 [inputZPosition doubleValue]);
	
	glRotated([inputXRotation doubleValue],1.0,0.0,0.0);
	glRotated([inputYRotation doubleValue],0.0,1.0,0.0);
	glRotated([inputZRotation doubleValue],0.0,0.0,1.0);*/
	
	double (*evaluate)(id, SEL) = (double (*)(id, SEL))[(NSObject*)rExpression methodForSelector:@selector(evaluate)];
	void (*setVariableAtIndex)(id, SEL, double, NSInteger) = (void (*)(id, SEL, double, NSInteger))[rExpression methodForSelector:@selector(setVariable:atIndex:)];
	
	glBegin(GL_LINE_STRIP);
	double t = 0;
	for(i=0;i<steps;++i)
	{
		if(trIndex != NSNotFound)
			setVariableAtIndex(rExpression, nil, t, trIndex);
		if(tgIndex != NSNotFound)
			setVariableAtIndex(gExpression, nil, t, tgIndex);
		if(tbIndex != NSNotFound)
			setVariableAtIndex(bExpression, nil, t, tbIndex);
		if(taIndex != NSNotFound)
			setVariableAtIndex(aExpression, nil, t, taIndex);
		glColor4d(evaluate(rExpression, nil),
				  evaluate(gExpression, nil),
				  evaluate(bExpression, nil),
				  evaluate(aExpression, nil));
		
		if(txIndex != NSNotFound)
			setVariableAtIndex(xExpression, nil, t, txIndex);
		if(tyIndex != NSNotFound)
			setVariableAtIndex(yExpression, nil, t, tyIndex);
		if(tzIndex != NSNotFound)
			setVariableAtIndex(zExpression, nil, t, tzIndex);
		glVertex3d(evaluate(xExpression, nil),
				   evaluate(yExpression, nil),
				   evaluate(zExpression, nil));
		t += rSteps;
	}
	glEnd();
	glPopMatrix();
	glLineWidth(oldWidth);
	if([inputPattern indexValue] != 0xffff)
		glLineStipple(oldFactor, oldPattern);
	
	[inputBlending unsetOnOpenGLContext: context];
	[inputDepth unsetOnOpenGLContext: context];

	return YES;
}

@end
