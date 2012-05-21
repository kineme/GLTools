/*
 *  KinemeGLGridEditorPatch.m
 *  GLTools
 *
 *  Created by Christopher Wright on 8/16/09.
 *  Copyright (c) 2009 Kosada Incorporated. All rights reserved.
 *
 */

#import "KinemeGLGridEditorPatch.h"

@implementation KinemeGLGridEditorPatch : QCPatch

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
		[[self userInfo] setObject:@"Kineme GL Grid Editor" forKey:@"name"];
	}
	
	return self;
}

- (void)cleanup:(QCOpenGLContext *)context
{
	if(vertex)
		free(vertex);
	vertex = NULL;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	unsigned int x, y;	
	if(vertex == NULL || [inputGrid wasUpdated] || [inputResetGrid booleanValue])
	{
		selected = 0;
		QCStructure *grid = [inputGrid structureValue];
		width = [[grid memberForKey:@"width"] intValue];
		height = [[grid memberForKey:@"height"] intValue];
		if(width == 0 || height == 0)
		{
			[outputGrid setStructureValue:nil];
			return YES;
		}
		vertex = (KinemeVertex*)realloc(vertex, sizeof(KinemeVertex)*(width+1)*(height+1));
		
		CGFloat r, g, b, a;
		[inputColor getRed:&r green:&g blue:&b alpha:&a];

		QCStructure *vertexStruct;
		
		for(y = 0; y <= height; ++y)
			for(x = 0; x <= width; ++x)
			{
				id key = [[NSString allocWithZone:NULL] initWithFormat:@"vertex_%i",1+y*(width+1)+x];
				vertexStruct = [grid memberForKey:key];
				[key release];	// don't flood the autorelease pool
				vertex[y*(width+1)+x].x = [[vertexStruct memberForKey:@"x"] doubleValue];
				vertex[y*(width+1)+x].y = [[vertexStruct memberForKey:@"y"] doubleValue];
				vertex[y*(width+1)+x].z = [[vertexStruct memberForKey:@"z"] doubleValue];
				vertex[y*(width+1)+x].r = r;
				vertex[y*(width+1)+x].g = g;
				vertex[y*(width+1)+x].b = b;
				vertex[y*(width+1)+x].a = a;
				vertex[y*(width+1)+x].u = [[vertexStruct memberForKey:@"u"] doubleValue];
				vertex[y*(width+1)+x].v = [[vertexStruct memberForKey:@"v"] doubleValue];
			}
	}
	if(width == 0 || height == 0)
	{
		[outputGrid setStructureValue:nil];
		return YES;
	}
	
	if([inputAutoIncrementOnCommit booleanValue] == FALSE)
		selected = [inputSelection indexValue] % ((width+1)*(height+1));
	
	/* modification mode */
	if([inputSelectionEnabled booleanValue] == TRUE)
	{
		//NSLog(@"selection is enabled");
		// This is a bit different: we want falling edge so mouse input is intuitive (drag-and-release)
		if([inputCommitChanges booleanValue] == TRUE && oldCommitValue == FALSE)
		{
			//NSLog(@"Commiting Changes to %i",selected);
			//selected = [inputSelection indexValue];
			//selected %= (width+1)*(height+1);
			vertex[selected].x = [inputX doubleValue];
			vertex[selected].y = [inputY doubleValue];
			vertex[selected].z = [inputZ doubleValue];
			if([inputU doubleValue] >= 0.0)
			{
				//NSLog(@"u is %f, updating",[inputU doubleValue]);
				vertex[selected].u = [inputU doubleValue];
			}
			if([inputV doubleValue] >= 0.0)
			{
				//NSLog(@"v is %f, updating",[inputV doubleValue]);
				vertex[selected].v = [inputV doubleValue];
			}
			
			[inputColor getRed:&vertex[selected].r
						 green:&vertex[selected].g
						  blue:&vertex[selected].b
						 alpha:&vertex[selected].a];
			/*if([inputAutoIncrementOnCommit booleanValue] == TRUE)
			{
				++selected;
				[inputSelection setIndexValue: selected];
				oldSelectionValue = FALSE;	// need the next block to execute to fill in proper values
			}*/
			{
				unsigned int nextSelected = (selected + 1) % ((width+1) * (height+1));
				[inputX setDoubleValue:vertex[nextSelected].x];
				[inputY setDoubleValue:vertex[nextSelected].y];
				[inputZ setDoubleValue:vertex[nextSelected].z];
				[inputU setDoubleValue:vertex[nextSelected].u];
				[inputV setDoubleValue:vertex[nextSelected].v];
				[inputColor setRed:vertex[nextSelected].r
							 green:vertex[nextSelected].g
							  blue:vertex[nextSelected].b
							 alpha:vertex[nextSelected].a];
			}
		}
		if(oldSelectionValue == FALSE)	// rising edge.  populate inputs
		{
			[inputX setDoubleValue:vertex[selected].x];
			[inputY setDoubleValue:vertex[selected].y];
			[inputZ setDoubleValue:vertex[selected].z];
			[inputU setDoubleValue:vertex[selected].u];
			[inputV setDoubleValue:vertex[selected].v];
			[inputColor setRed:vertex[selected].r
						 green:vertex[selected].g
						  blue:vertex[selected].b
						 alpha:vertex[selected].a];
		}
	}
		
	/* generate the grid structure */
	NSMutableArray *meshArray = [[NSMutableArray allocWithZone:NULL] initWithCapacity:(width+1)*(height+1)];
	for(y = 0; y <= height; ++y)
	{
		for(x = 0; x <= width; ++x)
		{
			QCStructure *vertexStructure = [[QCStructure allocWithZone:NULL] init];
			// this hammers the autorelease pool -- nsnumber is pricey :/
			if( y*(width+1)+x == selected && [inputSelectionEnabled booleanValue] == TRUE)
			{
				//NSLog(@"overriding %i",selected);
				
				[vertexStructure setMember:[NSNumber numberWithDouble: [inputX doubleValue]] forKey:@"x"];
				[vertexStructure setMember:[NSNumber numberWithDouble: [inputY doubleValue]] forKey:@"y"];
				[vertexStructure setMember:[NSNumber numberWithDouble: [inputZ doubleValue]] forKey:@"z"];
				if([inputU doubleValue] >= 0.0)
					[vertexStructure setMember:[NSNumber numberWithDouble: [inputU doubleValue]] forKey:@"u"];
				else
					[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].u] forKey:@"u"];
				if([inputV doubleValue] >= 0.0)
					[vertexStructure setMember:[NSNumber numberWithDouble: [inputV doubleValue]] forKey:@"v"];
				else
					[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].v] forKey:@"v"];
				[vertexStructure setMember:[NSNumber numberWithDouble: [inputColor redComponent]] forKey:@"r"];
				[vertexStructure setMember:[NSNumber numberWithDouble: [inputColor greenComponent]] forKey:@"g"];
				[vertexStructure setMember:[NSNumber numberWithDouble: [inputColor blueComponent]] forKey:@"b"];
				[vertexStructure setMember:[NSNumber numberWithDouble: [inputColor alphaComponent]] forKey:@"a"];
			}
			else
			{
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].x] forKey:@"x"];
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].y] forKey:@"y"];
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].z] forKey:@"z"];
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].u] forKey:@"u"];
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].v] forKey:@"v"];
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].r] forKey:@"r"];
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].g] forKey:@"g"];
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].b] forKey:@"b"];
				[vertexStructure setMember:[NSNumber numberWithDouble: vertex[y*(width+1)+x].a] forKey:@"a"];
			}
			
			[meshArray addObject:vertexStructure];
			[vertexStructure release];
		}
	}
	
	QCStructure *meshStructure = [[QCStructure allocWithZone:NULL] initWithMembers:meshArray keyPrefix:@"vertex_"];
	[meshArray release];
	[meshStructure setMember:[NSNumber numberWithInt:width] forKey:@"width"];
	[meshStructure setMember:[NSNumber numberWithInt:height] forKey:@"height"];
	
	[outputGrid setStructureValue: meshStructure];
	[meshStructure release];
	
	// it's safe to auto increment now
	if(	[inputAutoIncrementOnCommit booleanValue] == TRUE &&
	   [inputCommitChanges booleanValue] == TRUE && oldCommitValue == FALSE)
		selected = (selected + 1) % ((width+1) * (height+1));
	
	[outputSelection setIndexValue:selected];
	
	oldSelectionValue = [inputSelectionEnabled booleanValue];
	oldCommitValue = [inputCommitChanges booleanValue];
	
	return YES;
}

@end
