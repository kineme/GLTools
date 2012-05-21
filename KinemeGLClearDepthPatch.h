/*
 *  GLClearDepth.h
 *  GLTools
 *
 *  Created by Christopher Wright on 9/17/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */



@interface KinemeGLClearDepthPatch : QCPatch
{
    QCNumberPort *inputDepth;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end