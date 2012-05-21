//
//  GLReadPixels.h
//  GLTools
//
//  Created by Christopher Wright on 1/15/08.
//  Copyright 2008 Kosada Incorporated. All rights reserved.



@interface KinemeGLReadPixelsPatch : QCPatch
{
	QCBooleanPort	*inputRecord;
	//QCIndexPort	*inputX;
	//QCIndexPort	*inputY;
	//QCIndexPort	*inputWidth;
	//QCIndexPort	*inputHeight;
	QCIndexPort	*inputSource;
	QCBooleanPort	*inputIsFlipped;
	
	QCImagePort	*outputImage;
	
	//char *data, *flipData;
	unsigned int width, height;
	CGColorSpaceRef cs;
	GLuint		texture;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;

@end
