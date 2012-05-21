/*
 *  KinemeGLGridGeneratorPatch.m
 *  GLTools
 *
 *  Created by Christopher Wright on 8/16/09.
 *  Copyright (c) 2009 Kosada Incorporated. All rights reserved.
 *
 */

#import "KinemeGLGridGeneratorPatch.h"

@implementation KinemeGLGridGeneratorPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 0;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
		[[self userInfo] setObject:@"Kineme GL Grid Generator" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	unsigned int x, y;
	unsigned int width, height;
	KinemeVertex *vertex;
	
	{
		width = [inputWidth indexValue];
		height = [inputHeight indexValue];
		if(width && height)
			vertex = (KinemeVertex*)malloc(sizeof(KinemeVertex)*(width+1)*(height+1));
		else
		{
			[outputGrid setValue:nil];
			return YES;
		}
	}
	
	{
		//NSLog(@"regenerating");		
		for(y = 0; y <= height; ++y)
		{
			for(x = 0; x<= width; ++x)
			{
				vertex[y*(width+1)+x].x = ((float)x)/width - 0.5f;
				vertex[y*(width+1)+x].y = ((float)y)/height - 0.5f;
				vertex[y*(width+1)+x].z = 0.0;
				vertex[y*(width+1)+x].r = 1;
				vertex[y*(width+1)+x].g = 1;
				vertex[y*(width+1)+x].b = 1;
				vertex[y*(width+1)+x].a = 1;
				vertex[y*(width+1)+x].u = ((float)x)/width;
				vertex[y*(width+1)+x].v = ((float)y)/height;
			}
		}
	}
	
	/* generate the grid structure */
	NSMutableArray *meshArray = [[NSMutableArray alloc] initWithCapacity:(width+1)*(height+1)];
	for(y = 0; y <= height; ++y)
	{
		for(x = 0; x <= width; ++x)
		{
			QCStructure *vertexStructure = [[QCStructure alloc] init];

			{
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].x] forKey:@"x"];
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].y] forKey:@"y"];
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].z] forKey:@"z"];
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].u] forKey:@"u"];
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].v] forKey:@"v"];
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].r] forKey:@"r"];
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].g] forKey:@"g"];
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].b] forKey:@"b"];
				[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].a] forKey:@"a"];
			}
			
			
			[meshArray addObject:vertexStructure];
			[vertexStructure release];
		}
	}
	
	QCStructure *meshStructure = [[QCStructure alloc] initWithMembers:meshArray keyPrefix:@"vertex_"];
	[meshArray release];
	[meshStructure setMember:[NSNumber numberWithInt:width] forKey:@"width"];
	[meshStructure setMember:[NSNumber numberWithInt:height] forKey:@"height"];
	
	[outputGrid setStructureValue: meshStructure];
	[meshStructure release];
	free(vertex);
	
	return YES;
}

@end
