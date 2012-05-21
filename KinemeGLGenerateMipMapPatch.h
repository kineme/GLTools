//
//  KinemeGLGenerateMipMapPatch.h
//  GLTools
//
//  Created by Christopher Wright on 12/17/08.
//  Copyright 2008 Kosada Incorporated. All rights reserved.
//



@interface KinemeGLGenerateMipMapPatch : QCPatch
{
	QCOpenGLPort_Image *inputImage;
	QCOpenGLPort_Image *outputImage;
	
	QCNumberPort	*inputAniso;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;

@end
