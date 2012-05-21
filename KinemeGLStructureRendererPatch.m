#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLStructureRendererPatch.h"


static float safeFloatValue(NSNumber *n,float defaultValue)
{
	if(n)
	{
		float (*floatValue)() = (float (*)())[NSNumber instanceMethodForSelector:@selector(floatValue)];
		return floatValue(n);
	}

	return defaultValue;
}

@implementation KinemeGLStructureRendererPatch
+(BOOL)isSafe
{
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return YES;
}

+(QCPatchExecutionMode)executionModeWithIdentifier:(id)identifier
{
	return kQCPatchExecutionModeConsumer;
}

+ (BOOL)supportsOptimizedExecutionForIdentifier:(id)identifier
{
	return YES;
}

-(id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Kineme GL Structure Renderer" forKey:@"name"];
	}
	return self;
}

-(BOOL)setup:(QCOpenGLContext*)context
{
	return YES;
}

-(void)cleanup:(QCOpenGLContext*)context
{
}

-(void)enable:(QCOpenGLContext*)context
{
}

-(void)disable:(QCOpenGLContext*)context
{
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	QCStructure *transformStruct = [inputTransformStructure structureValue];
	NSUInteger count = [transformStruct count];

	if(!transformStruct)
		return YES;	// no points -- do nothing
	if(count == 0)
		return YES;	// no points -- do nothing

	CGLContextObj cgl_ctx = [context CGLContextObj];
	Class QCStructureClass = [QCStructure class];
	Class NSArrayClass = [NSArray class];
	BOOL keyed = (count && [[transformStruct memberAtIndex:0] isKindOfClass:QCStructureClass] && 
				  [[transformStruct memberAtIndex:0] memberForKey:@"X"] != nil);

	glMatrixMode(GL_MODELVIEW);
	glEnable(GL_NORMALIZE); 

	for(id transform in (GFList*)[transformStruct _list])
	{
		if( [self respondsToSelector:@selector(invalidateDodForSubpatches)] )
		{
			// this pattern is copied from QCReplicator's execute method.
			[self invalidateDodForSubpatches];
			id rm = object_getIvar(self, class_getInstanceVariable([QCPatch class], "_renderingManager"));
			[rm _nextFrame];
		}

		glPushMatrix();

			if([transform isKindOfClass: QCStructureClass])
			{
				if(keyed)
				{
					glTranslatef(safeFloatValue([transform memberForKey:@"X"],0),
								 safeFloatValue([transform memberForKey:@"Y"],0),
								 safeFloatValue([transform memberForKey:@"Z"],0));

					glRotatef(safeFloatValue([transform memberForKey:@"RX"],0),1,0,0);
					glRotatef(safeFloatValue([transform memberForKey:@"RY"],0),0,1,0);
					glRotatef(safeFloatValue([transform memberForKey:@"RZ"],0),0,0,1);

					glScalef(safeFloatValue([transform memberForKey:@"SX"],1),
							 safeFloatValue([transform memberForKey:@"SY"],1),
							 safeFloatValue([transform memberForKey:@"SZ"],1));
				}
				else
				{
					glTranslatef(safeFloatValue([transform memberAtIndex:0],0),
								 safeFloatValue([transform memberAtIndex:1],0),
								 safeFloatValue([transform memberAtIndex:2],0));
				}
			}
			else if( [transform isKindOfClass:NSArrayClass] )
			{
				glTranslatef(safeFloatValue([(NSArray *)transform objectAtIndex:0],0),
							 safeFloatValue([(NSArray *)transform objectAtIndex:1],0),
							 safeFloatValue([(NSArray *)transform objectAtIndex:2],0));
			}

			[self executeSubpatches:time arguments:arguments];

		glPopMatrix();
	}
	
	return YES;
}

@end
