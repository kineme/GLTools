#import "KinemeGLGridPatch.h"

@implementation KinemeGLGridPatch : QCPatch

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
	self=[super initWithIdentifier:fp8];

	if(self)
	{
		width = 0;
		height = 0;
		selected = 0;
		oldCommitValue = FALSE;
		oldSelectionValue = FALSE;
		vertex = NULL;
		[inputColor setRed:0.7
					green:0.8
					blue:0.7
					alpha:0.7];
		[inputWidth setIndexValue:4];
		[inputHeight setIndexValue:4];
		[inputU setDoubleValue:-1.0];
		[inputV setDoubleValue:-1.0];
		[[self userInfo] setObject:@"Kineme GL Grid Generator" forKey:@"name"];
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
	BOOL regenerate = FALSE;

	if(vertex == NULL || [inputResetGrid booleanValue] || 
	   [inputWidth indexValue] != width || [inputHeight indexValue] != height)
	{
		//NSLog(@"reconfiguring to %i x %i",[inputWidth indexValue], [inputHeight indexValue]);
		selected = 0;
		width = [inputWidth indexValue];
		height = [inputHeight indexValue];
		if(width && height)
		{
			vertex = (KinemeVertex*)realloc(vertex, sizeof(KinemeVertex)*(width+1)*(height+1));
			regenerate = TRUE;
		}
		else
		{
			if(vertex)
				free(vertex);
			vertex = NULL;
			[outputGrid setValue:nil];
			return YES;
		}
	}
		
	if([inputAutoIncrementOnCommit booleanValue] == FALSE)
		selected = [inputSelection indexValue] % ((width+1)*(height+1));
	
	if(regenerate)
	{
		//NSLog(@"regenerating");
		CGFloat r, g, b, a;
		[inputColor getRed:&r green:&g blue:&b alpha:&a];
		
		for(y = 0; y <= height; ++y)
		{
			for(x = 0; x<= width; ++x)
			{
				vertex[y*(width+1)+x].x = ((float)x)/width - 0.5f;
				vertex[y*(width+1)+x].y = ((float)y)/height - 0.5f;
				vertex[y*(width+1)+x].z = 0.0;
				vertex[y*(width+1)+x].r = r;
				vertex[y*(width+1)+x].g = g;
				vertex[y*(width+1)+x].b = b;
				vertex[y*(width+1)+x].a = a;
				vertex[y*(width+1)+x].u = ((float)x)/width;
				vertex[y*(width+1)+x].v = ((float)y)/height;
			}
		}
	}
	
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
			vertex[selected].r = [inputColor redComponent];
			vertex[selected].g = [inputColor greenComponent];
			vertex[selected].b = [inputColor blueComponent];
			vertex[selected].a = [inputColor alphaComponent];
			/*if([inputAutoIncrementOnCommit booleanValue] == TRUE)
			{
				++selected;
				[inputSelection setIndexValue: selected];
				oldSelectionValue = FALSE;	// need the next block to execute to fill in proper values
			}*/
		}
		if(oldSelectionValue == FALSE)	// rising edge.  populate inputs
		{
			[inputX setDoubleValue:vertex[selected].x];
			[inputY setDoubleValue:vertex[selected].y];
			[inputZ setDoubleValue:vertex[selected].z];
			//[inputU setDoubleValue:vertex[selected].u];
			//[inputV setDoubleValue:vertex[selected].v];
			[inputColor setRed:vertex[selected].r
						green:vertex[selected].g
						blue:vertex[selected].b
						alpha:vertex[selected].a];
		}
	}
	
	if(width == 0 || height == 0)
	{
		[outputGrid setStructureValue:nil];
		return YES;
	}
	
	/* generate the grid structure */
	NSMutableArray *meshArray = [[NSMutableArray alloc] initWithCapacity:(width+1)*(height+1)];
	for(y = 0; y <= height; ++y)
	{
		for(x = 0; x <= width; ++x)
		{
			QCStructure *vertexStructure = [[QCStructure alloc] init];
			
			if( y*(width+1)+x == selected && [inputSelectionEnabled booleanValue] == TRUE)
			{
				//NSLog(@"overriding %i",selected);
				[vertexStructure setMember:[NSNumber numberWithFloat: [inputX doubleValue]] forKey:@"x"];
				[vertexStructure setMember:[NSNumber numberWithFloat: [inputY doubleValue]] forKey:@"y"];
				[vertexStructure setMember:[NSNumber numberWithFloat: [inputZ doubleValue]] forKey:@"z"];
				if([inputU doubleValue] >= 0.0)
					[vertexStructure setMember:[NSNumber numberWithFloat: [inputU doubleValue]] forKey:@"u"];
				else
					[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].u] forKey:@"u"];
				if([inputV doubleValue] >= 0.0)
					[vertexStructure setMember:[NSNumber numberWithFloat: [inputV doubleValue]] forKey:@"v"];
				else
					[vertexStructure setMember:[NSNumber numberWithFloat: vertex[y*(width+1)+x].v] forKey:@"v"];
				//[vertexStructure setMember:[NSNumber numberWithFloat: [inputV doubleValue]] forKey:@"v"];
				[vertexStructure setMember:[NSNumber numberWithFloat: [inputColor redComponent]] forKey:@"r"];
				[vertexStructure setMember:[NSNumber numberWithFloat: [inputColor greenComponent]] forKey:@"g"];
				[vertexStructure setMember:[NSNumber numberWithFloat: [inputColor blueComponent]] forKey:@"b"];
				[vertexStructure setMember:[NSNumber numberWithFloat: [inputColor alphaComponent]] forKey:@"a"];
			}
			else
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
