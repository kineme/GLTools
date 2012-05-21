#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLSplinePatch.h"
#import "KinemeGLSplinePatchUI.h"

@implementation KinemeGLSplinePatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}
+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8
{
	return [KinemeGLSplinePatchUI class];
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	self=[super initWithIdentifier:fp8];
	if(self)
	{
		// start with a sane tension
		[inputTension setDoubleValue:2.0];
		// start with a nice step
		[inputSubdivisions setIndexValue:200];

		[inputShowPoints setBooleanValue:TRUE];

		[inputStipple setIndexValue: 65535];
		[inputStipple setMaxIndexValue: 65535];
		[inputStippleScale setIndexValue: 1];

		[inputWidth setMinDoubleValue: 0.4];
		[inputWidth setDoubleValue: 1.0];
		[inputPointSize setDoubleValue: 8.0];
		[inputPointSize setMinDoubleValue: 0.4];
		
		[inputBlending setIndexValue:3];	// set Alpha blend mode by default

		// start out with 3 points, so we show a nice spline
		[self addPoint];
		[self addPoint];
		[self addPoint];
		[xArray[0] setDoubleValue:-0.5];
		[yArray[1] setDoubleValue: 0.5];
		[xArray[2] setDoubleValue: 0.5];
		[colorArray[0] setRed:0.7 green:0.4 blue:0.4 alpha:0.9];
		[colorArray[1] setRed:0.4 green:0.4 blue:0.7 alpha:0.9];
		[colorArray[2] setRed:0.4 green:0.7 blue:0.4 alpha:0.9];
		
		[[self userInfo] setObject:@"Kineme GL Spline" forKey:@"name"];
	}
	return self;
}

- (void)dealloc
{
	free(xArray);
	free(yArray);
	free(zArray);
	free(colorArray);
	free(ptsx);
	free(ptsy);
	free(ptsz);
	[super dealloc];
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLint	smoothLines;
	GLint	smoothPoints;
	
	if(controlPoints < 1)
		return YES;

	GLfloat origLineWidth;
	GLfloat origPointSize;

	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glGetFloatv(GL_POINT_SIZE,&origPointSize);
	glGetFloatv(GL_LINE_WIDTH,&origLineWidth);

	glLineWidth([inputWidth doubleValue]);
	
	int i;
	
	// local ivar cache
	float *lptsx = ptsx, *lptsy = ptsy, *lptsz = ptsz;
	
	for(i=0;i<controlPoints;++i)
	{
		lptsx[i] = [xArray[i] doubleValue];
		lptsy[i] = [yArray[i] doubleValue];
		lptsz[i] = [zArray[i] doubleValue];		
	}
	
	float t;
	// this isn't technically necessary, but good form
	if([inputSubdivisions indexValue] == 0)
		[inputSubdivisions setIndexValue:1];
		
	float steps = 1.0f/(float)[inputSubdivisions indexValue];	// move some message stuff out of the loop
	
	float p[3];//px, py, pz;
	float B0, B1, B2, B3;
	
	smoothLines = glIsEnabled(GL_LINE_SMOOTH);
	if(!smoothLines)
		glEnable(GL_LINE_SMOOTH);
	smoothPoints = glIsEnabled(GL_POINT_SMOOTH);
	if(!smoothPoints)
		glEnable(GL_POINT_SMOOTH);

	[inputBlending setOnOpenGLContext: context];
	[inputDepth setOnOpenGLContext: context];
	
	float a = 1.0f/(float)[inputTension doubleValue];
		
	int i0, i1, i2;
	CGFloat r1, g1, b1, a1, r2, g2, b2, a2, dr, dg, db, da;
	
	[colorArray[0] getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
	
	unsigned int stipple = [inputStipple indexValue], stippleScale = [inputStippleScale indexValue];
	unsigned int stipplePos = 0, stippleOn = stipple&1;
		
	glNormal3b(0,0,0);
	
	if(stippleScale == 0)
		stippleScale = 1;
	if(stipple == 65535 || stippleOn)	// no stippling
		glBegin(GL_LINE_STRIP);
	
	for (i = 0; i < controlPoints - 1; i++)
	{
		if(stippleOn)
			glVertex3f(ptsx[i], ptsy[i], ptsz[i]);

		i0 = (i == 0) ? controlPoints - 1 : i - 1;
		i1 = (i == controlPoints - 1) ? 0 : i + 1;
		i2 = (i >= controlPoints - 2) ? ((i == controlPoints - 1) ? 1 : 0) : i + 2;
		
		// ...move more messages out of the inner loop...		
		r1=r2;
		g1=g2;
		b1=b2;
		a1=a2;
		[colorArray[i+1] getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
		
		dr = (r2 - r1)*steps;
		dg = (g2 - g1)*steps;
		db = (b2 - b1)*steps;
		da = (a2 - a1)*steps;
				
		for (t = 0; t <= 1.; t+= steps)
		{
			/* several years ago(1999-2000ish?), I found that CSE'ing spline equations like these yielded signifigant performance benefits.
				This probably isn't the case anymore, but it might be a fun experiment.
				
				for example, t*t is used twice, as is (1-t)*(1-t).  I'm hoping modern CSE optimization passes catch this already...
			 
				experiments show that this is ~2-5% faster still :/  so much for CSE passes catching simple stuff... */
			float tm1 = (1.f-t) * (1.f-t);
			float tt = t * t;
			B0 = tm1*(1.f-t);
			B1 = 3.f*t*tm1;
			B2 = 3.f*tt*(1.f-t);
			B3 = t*tt;
					
			p[0] = lptsx[i]*B0 + (lptsx[i] + (lptsx[i1] - lptsx[i0])*a)*B1 + (lptsx[i1] - (lptsx[i2] - lptsx[i])*a)*B2 + lptsx[i1]*B3;
			p[1] = lptsy[i]*B0 + (lptsy[i] + (lptsy[i1] - lptsy[i0])*a)*B1 + (lptsy[i1] - (lptsy[i2] - lptsy[i])*a)*B2 + lptsy[i1]*B3;
			p[2] = lptsz[i]*B0 + (lptsz[i] + (lptsz[i1] - lptsz[i0])*a)*B1 + (lptsz[i1] - (lptsz[i2] - lptsz[i])*a)*B2 + lptsz[i1]*B3;
			if(stipple != 0xffff)	// common case
			{
				if(stippleOn)
				{
					KIGLColor4(r1,g1,b1,a1);
					glVertex3fv(p);
				}
				stipplePos++;
				if(stippleOn)	// check for off-ness
				{
					//NSLog(@"%i %i %i %i %i",stipple, stipplePos, (stipplePos/stippleScale)%16,(1 << ((stipplePos/stippleScale)%16)), stipple & (1 << ((stipplePos/stippleScale)%16)));
					if( (stipple & (1 << ((stipplePos/stippleScale)%16))) == 0)
					{
						//NSLog(@"%x %x %i off",stipple, stipplePos, stippleScale);
						stippleOn = 0;
						glEnd();
					}
				}
				else	// check for on-ness
				{
					if( (stipple & (1 << ((stipplePos/stippleScale)%16))) != 0)
					{
						//NSLog(@"%x %x %i on",stipple, stipplePos, stippleScale);
						glBegin(GL_LINE_STRIP);
						stippleOn = 1;
					}
				}
			}
			else
			{
				KIGLColor4(r1,g1,b1,a1);
				glVertex3fv(p);
			}
			
			r1 += dr;
			g1 += dg;
			b1 += db;
			a1 += da;
		}

		glVertex3f(lptsx[i1], lptsy[i1], lptsz[i1]);
	}
	
	if(stipple == 65535 || stippleOn)
		glEnd();

	if([inputShowPoints booleanValue] == TRUE || [inputShowSubdivisionPoints booleanValue] == TRUE)
	{
		glPointSize([inputPointSize doubleValue]);
		//glEnable(GL_POINT_SMOOTH);
		glHint(GL_POINT_SMOOTH_HINT,GL_NICEST);
		glBegin(GL_POINTS);
		if(![inputShowSubdivisionPoints booleanValue])
		{
			KIGLColor4([inputPointColor redComponent], [inputPointColor greenComponent], [inputPointColor blueComponent],[inputPointColor alphaComponent]);
			BOOL usePointColor = [inputUsePointColor booleanValue];
			for(i=0;i<controlPoints;++i)
			{
				if(usePointColor == FALSE)
					KIGLColor4([colorArray[i] redComponent], [colorArray[i] greenComponent], [colorArray[i] blueComponent],[colorArray[i] alphaComponent]);
				glVertex3f(lptsx[i],lptsy[i],lptsz[i]);
			}
		}
		else	// show points and subdivisions
		{
			[colorArray[0] getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

			for (i = 0; i < controlPoints - 1; i++)
			{
				glVertex3f(lptsx[i], lptsy[i], lptsz[i]);

				i0 = (i == 0) ? controlPoints - 1 : i - 1;
				i1 = (i == controlPoints - 1) ? 0 : i + 1;
				i2 = (i >= controlPoints - 2) ? ((i == controlPoints - 1) ? 1 : 0) : i + 2;
		
				// ...move more messages out of the inner loop...
				r1=r2;
				g1=g2;
				b1=b2;
				a1=a2;
				[colorArray[i+1] getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
				dr = (r2 - r1)*steps;
				dg = (g2 - g1)*steps;
				db = (b2 - b1)*steps;
				da = (a2 - a1)*steps;
				
		
				for (t = 0; t <= 1.; t+= steps)
				{
					/* several years ago(1999-2000ish?), I found that CSE'ing spline equations like these yielded signifigant performance benefits.
						This probably isn't the case anymore, but it might be a fun experiment.
				
						for example, t*t is used twice, as is (1-t)*(1-t).  I'm hoping modern CSE optimization passes catch this already...*/
					float tm1 = (1.f-t) * (1.f-t);
					float tt = t * t;
					B0 = tm1*(1.f-t);
					B1 = 3.f*t*tm1;
					B2 = 3.f*tt*(1.f-t);
					B3 = t*tt;
					
					p[0] = lptsx[i]*B0 + (lptsx[i] + (lptsx[i1] - lptsx[i0])*a)*B1 + (lptsx[i1] - (lptsx[i2] - lptsx[i])*a)*B2 + lptsx[i1]*B3;
					p[1] = lptsy[i]*B0 + (lptsy[i] + (lptsy[i1] - lptsy[i0])*a)*B1 + (lptsy[i1] - (lptsy[i2] - lptsy[i])*a)*B2 + lptsy[i1]*B3;
					p[2] = lptsz[i]*B0 + (lptsz[i] + (lptsz[i1] - lptsz[i0])*a)*B1 + (lptsz[i1] - (lptsz[i2] - lptsz[i])*a)*B2 + lptsz[i1]*B3;
					if(stippleOn)
					{
						KIGLColor4(r1,g1,b1,a1);
						glVertex3fv(p);
					}
					r1 += dr;
					g1 += dg;
					b1 += db;
					a1 += da;					
				}
			}
		}
		glEnd();
	}

	if(!smoothLines)
		glDisable(GL_LINE_SMOOTH);
	if(!smoothPoints)
		glDisable(GL_POINT_SMOOTH);
	[inputDepth unsetOnOpenGLContext: context];
	[inputBlending unsetOnOpenGLContext: context];
	
	glPointSize(origPointSize);
	glLineWidth(origLineWidth);

	return YES;
}

- (void)addPoint
{
	if(controlPoints<40)	// if we have more than 40 points, the patch doesn't fit within the composition editor..
	{
		++controlPoints;
		unsigned int lControlPoints = controlPoints;
		ptsx = (float*)NSReallocateCollectable(ptsx,(sizeof(float)*lControlPoints),0);
		ptsy = (float*)NSReallocateCollectable(ptsy,(sizeof(float)*lControlPoints),0);
		ptsz = (float*)NSReallocateCollectable(ptsz,(sizeof(float)*lControlPoints),0);
		
		xArray = (QCNumberPort**)NSReallocateCollectable(xArray, ((sizeof(QCNumberPort*)) * lControlPoints),NSScannedOption);
		yArray = (QCNumberPort**)NSReallocateCollectable(yArray, ((sizeof(QCNumberPort*)) * lControlPoints),NSScannedOption);
		zArray = (QCNumberPort**)NSReallocateCollectable(zArray, ((sizeof(QCNumberPort*)) * lControlPoints),NSScannedOption);
		colorArray = (QCColorPort**)NSReallocateCollectable(colorArray, ((sizeof(QCColorPort*)) * lControlPoints),NSScannedOption);

		[self disableNotifications];
		Class QCNumberPortClass = [QCNumberPort class];
		xArray[lControlPoints-1] = [self createInputWithPortClass:QCNumberPortClass forKey:[NSString stringWithFormat:@"X%i Position",lControlPoints] attributes:nil];
		yArray[lControlPoints-1] = [self createInputWithPortClass:QCNumberPortClass forKey:[NSString stringWithFormat:@"Y%i Position",lControlPoints] attributes:nil];
		zArray[lControlPoints-1] = [self createInputWithPortClass:QCNumberPortClass forKey:[NSString stringWithFormat:@"Z%i Position",lControlPoints] attributes:nil];
		[self enableNotifications];
		colorArray[lControlPoints-1] = [self createInputWithPortClass:[QCColorPort class] forKey:[NSString stringWithFormat:@"Color %i",lControlPoints] attributes:nil];
	}
}

- (void)removePoint
{
	if(controlPoints>2)
	{
		[self disableNotifications];
		[self deleteInputForKey:[NSString stringWithFormat:@"X%i Position",controlPoints]];
		[self deleteInputForKey:[NSString stringWithFormat:@"Y%i Position",controlPoints]];
		[self deleteInputForKey:[NSString stringWithFormat:@"Z%i Position",controlPoints]];
		[self enableNotifications];
		[self deleteInputForKey:[NSString stringWithFormat:@"Color %i",controlPoints]];
		
		--controlPoints;
		
		xArray = (QCNumberPort**)NSReallocateCollectable(xArray, ((sizeof(QCNumberPort*)) * (controlPoints)),NSScannedOption);
		yArray = (QCNumberPort**)NSReallocateCollectable(yArray, ((sizeof(QCNumberPort*)) * (controlPoints)),NSScannedOption);
		zArray = (QCNumberPort**)NSReallocateCollectable(zArray, ((sizeof(QCNumberPort*)) * (controlPoints)),NSScannedOption);
		colorArray = (QCColorPort**)NSReallocateCollectable(colorArray, ((sizeof(QCColorPort*)) * (controlPoints)),NSScannedOption);
		
		ptsx = (float*)NSReallocateCollectable(ptsx,(sizeof(float)*(controlPoints)),0);
		ptsy = (float*)NSReallocateCollectable(ptsy,(sizeof(float)*(controlPoints)),0);
		ptsz = (float*)NSReallocateCollectable(ptsz,(sizeof(float)*(controlPoints)),0);
	}
}

- (NSDictionary*)state
{
	int i;
	CGFloat r,g,b,a;

	NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] initWithCapacity:1+controlPoints*3];
	[stateDict addEntriesFromDictionary:[super state]];
	
	[stateDict setObject:[NSNumber numberWithInt:controlPoints] forKey:@"controlPoints"];
	
	for(i=0;i<controlPoints;++i)
	{
		[colorArray[i] getRed:&r green:&g blue:&b alpha:&a];
		
		[stateDict setObject:[NSNumber numberWithDouble: [xArray[i] doubleValue]] forKey:[NSString stringWithFormat:@"x%i",i]];
		[stateDict setObject:[NSNumber numberWithDouble: [yArray[i] doubleValue]] forKey:[NSString stringWithFormat:@"y%i",i]];
		[stateDict setObject:[NSNumber numberWithDouble: [zArray[i] doubleValue]] forKey:[NSString stringWithFormat:@"z%i",i]];
		[stateDict setObject:[NSNumber numberWithFloat: r ]      forKey:[NSString stringWithFormat:@"r%i",i]];
		[stateDict setObject:[NSNumber numberWithFloat: g ]      forKey:[NSString stringWithFormat:@"g%i",i]];
		[stateDict setObject:[NSNumber numberWithFloat: b ]      forKey:[NSString stringWithFormat:@"b%i",i]];
		[stateDict setObject:[NSNumber numberWithFloat: a ]      forKey:[NSString stringWithFormat:@"a%i",i]];
	}

	[stateDict autorelease];
	return stateDict;
}

- (BOOL)setState:(NSDictionary*)state
{
	int i;

	/* clean up existing state, if it exists (init creates some) */
	[self disableNotifications];
	for(i=0;i<controlPoints;++i)
	{
		[self deleteInputForKey:[NSString stringWithFormat:@"X%i Position",i+1]];
		[self deleteInputForKey:[NSString stringWithFormat:@"Y%i Position",i+1]];
		[self deleteInputForKey:[NSString stringWithFormat:@"Z%i Position",i+1]];
		[self deleteInputForKey:[NSString stringWithFormat:@"Color %i",i+1]];
	}
	
	controlPoints = [[state objectForKey:@"controlPoints"] intValue];
	
	if(controlPoints < 2)
	{
		[self enableNotifications];
		return NO;
	}
	
	ptsx = (float*)NSReallocateCollectable(ptsx,(sizeof(float)*(controlPoints)),0);
	ptsy = (float*)NSReallocateCollectable(ptsy,(sizeof(float)*(controlPoints)),0);
	ptsz = (float*)NSReallocateCollectable(ptsz,(sizeof(float)*(controlPoints)),0);
	
	xArray = (QCNumberPort**)NSReallocateCollectable(xArray, ((sizeof(QCNumberPort*)) * (controlPoints)),NSScannedOption);
	yArray = (QCNumberPort**)NSReallocateCollectable(yArray, ((sizeof(QCNumberPort*)) * (controlPoints)),NSScannedOption);
	zArray = (QCNumberPort**)NSReallocateCollectable(zArray, ((sizeof(QCNumberPort*)) * (controlPoints)),NSScannedOption);
	colorArray = (QCColorPort**)NSReallocateCollectable(colorArray, ((sizeof(QCColorPort*)) * (controlPoints)),NSScannedOption);
	
	Class QCNumberPortClass = [QCNumberPort class];
	Class QCColorPortClass = [QCColorPort class];
	
	for(i=0;i<controlPoints;++i)
	{
		xArray[i] = [self createInputWithPortClass:QCNumberPortClass forKey:[NSString stringWithFormat:@"X%i Position",i+1] attributes:nil];
		yArray[i] = [self createInputWithPortClass:QCNumberPortClass forKey:[NSString stringWithFormat:@"Y%i Position",i+1] attributes:nil];
		zArray[i] = [self createInputWithPortClass:QCNumberPortClass forKey:[NSString stringWithFormat:@"Z%i Position",i+1] attributes:nil];
		colorArray[i] = [self createInputWithPortClass:QCColorPortClass forKey:[NSString stringWithFormat:@"Color %i",i+1] attributes:nil];
		
		if([state objectForKey:[NSString stringWithFormat:@"x%i",i]])
			[xArray[i] setDoubleValue:[[state objectForKey:[NSString stringWithFormat:@"x%i",i]] doubleValue]];
		else
			[xArray[i] setDoubleValue:0.0];
			
		if([state objectForKey:[NSString stringWithFormat:@"y%i",i]])
			[yArray[i] setDoubleValue:[[state objectForKey:[NSString stringWithFormat:@"y%i",i]] doubleValue]];
		else
			[yArray[i] setDoubleValue:0.0];
			
		if([state objectForKey:[NSString stringWithFormat:@"z%i",i]])
			[zArray[i] setDoubleValue:[[state objectForKey:[NSString stringWithFormat:@"z%i",i]] doubleValue]];
		else
			[zArray[i] setDoubleValue:0.0];
		
		[colorArray[i] setRed:	[[state objectForKey:[NSString stringWithFormat:@"r%i",i]] floatValue]
						green:	[[state objectForKey:[NSString stringWithFormat:@"g%i",i]] floatValue]
						blue:	[[state objectForKey:[NSString stringWithFormat:@"b%i",i]] floatValue]
						alpha:	[[state objectForKey:[NSString stringWithFormat:@"a%i",i]] floatValue]];
	}
	[self enableNotifications];
	// this restores default ports and position.
	[super setState:state];
	
	return YES;
}

@end
