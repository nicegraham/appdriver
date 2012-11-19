//
//  GlossGradients.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "GlossGradients.h"

#define MIN3(x,y,z)  ((y) <= (z) ? ((x) <= (y) ? (x) : (y)) : ((x) <= (z) ? (x) : (z)))
#define MAX3(x,y,z)  ((y) >= (z) ? ((x) >= (y) ? (x) : (y)) : ((x) >= (z) ? (x) : (z)))
						 
typedef struct
{
	CGFloat color[4];
	CGFloat caustic[4];
	CGFloat expCoefficient;
	CGFloat expScale;
	CGFloat expOffset;
	CGFloat initialWhite;
	CGFloat finalWhite;
} GlossParameters;

void rgb2hsv(CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v);
void hsv2rgb(CGFloat h, CGFloat s, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b);
static void glossInterpolation(void *info, const CGFloat *input, CGFloat *output);
CGFloat perceptualGlossFractionForColor(CGFloat *inputComponents);
void perceptualCausticColorForColor(CGFloat *inputComponents, CGFloat *outputComponents);

void rgb2hsv(CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v)
{
	*v = MAX3(r, g, b);
	if (*v == 0)
	{
		*h = 0;
		*s = 0;
		return;
	}
	
	r /= *v;
	g /= *v;
	b /= *v;
	
	*s = 1.0 - MIN3(r, g, b);
	if (*s == 0)
	{
		*h = 0;
		return;
	}
	
	if (r >= g && r >= b)
	{
		*h = 0.16666666667 * (g - b);
		if (*h < 0.0)
		{
			*h += 1.0;
		}
	}
	else if (g >= r && g >= b)
	{
		*h = 0.33333333333 + 0.16666666667 * (b - r);
	}
	else
	{
		*h = 0.66666666667 + 0.16666666667 * (r - g);
	}
}

void hsv2rgb(CGFloat h, CGFloat s, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b)
{
	if (s == 0.0)
	{
		*r = v;
		*g = v;
		*b = v;
	}
	else
	{
		CGFloat segment, offset, low, falling, rising;
		
		h = fmod(h, 1) * 6;
		
		segment = floor(h);
		offset = h - segment;

		low = v * (1 - s);
		falling = v * (1 - s * offset);
		rising = v * (1 - s * (1 - offset));

		if (segment == 0)
		{
			*r = v;
			*g = rising;
			*b = low;
		}
		else if (segment == 1)
		{
			*r = falling;
			*g = v;
			*b = low;
		}
		else if (segment == 2)
		{
			*r = low;
			*g = v;
			*b = rising;
		}
		else if (segment == 3)
		{
			*r = low;
			*g = falling;
			*b = v;
		}
		else if (segment == 4)
		{
			*r = rising;
			*g = low;
			*b = v;
		}
		else if (segment == 5)
		{
			*r = v;
			*g = low;
			*b = falling;
		}
   }
}

static void glossInterpolation(void *info, const CGFloat *input, CGFloat *output)
{
	GlossParameters *params = (GlossParameters *)info;

	CGFloat progress = *input;
	if (progress < 0.5)
	{
		progress = progress * 2.0;

		progress =
			1.0 - params->expScale * (expf(progress * -params->expCoefficient) - params->expOffset);

		CGFloat currentWhite = progress * (params->finalWhite - params->initialWhite) + params->initialWhite;
		
		output[0] = params->color[0] * (1.0 - currentWhite) + currentWhite;
		output[1] = params->color[1] * (1.0 - currentWhite) + currentWhite;
		output[2] = params->color[2] * (1.0 - currentWhite) + currentWhite;
		output[3] = params->color[3] * (1.0 - currentWhite) + currentWhite;
	}
	else
	{
		progress = (progress - 0.5) * 2.0;

		progress = params->expScale *
			(expf((1.0 - progress) * -params->expCoefficient) - params->expOffset);

		output[0] = params->color[0] * (1.0 - progress) + params->caustic[0] * progress;
		output[1] = params->color[1] * (1.0 - progress) + params->caustic[1] * progress;
		output[2] = params->color[2] * (1.0 - progress) + params->caustic[2] * progress;
		output[3] = params->color[3] * (1.0 - progress) + params->caustic[3] * progress;
	}
}

CGFloat perceptualGlossFractionForColor(CGFloat *inputComponents)
{
	const CGFloat REFLECTION_SCALE_NUMBER = 0.2;
    const CGFloat NTSC_RED_FRACTION = 0.299;
    const CGFloat NTSC_GREEN_FRACTION = 0.587;
	const CGFloat NTSC_BLUE_FRACTION = 0.114;

	CGFloat glossScale =
		NTSC_RED_FRACTION * inputComponents[0] +
		NTSC_GREEN_FRACTION * inputComponents[1] +
		NTSC_BLUE_FRACTION * inputComponents[2];
	glossScale = pow(glossScale, REFLECTION_SCALE_NUMBER);
	return glossScale;
}

void perceptualCausticColorForColor(CGFloat *inputComponents, CGFloat *outputComponents)
{
	const CGFloat CAUSTIC_FRACTION = 0.5;
	const CGFloat COSINE_ANGLE_SCALE = 1.4;
	const CGFloat MIN_RED_THRESHOLD = 0.95;
	const CGFloat MAX_BLUE_THRESHOLD = 0.7;
	const CGFloat GRAYSCALE_CAUSTIC_SATURATION = 0.15;
	
	CGFloat hue, saturation, brightness;
	rgb2hsv(inputComponents[0], inputComponents[1], inputComponents[2], &hue, &saturation, &brightness);

	CGFloat targetHue, targetSaturation, targetBrightness;
	rgb2hsv(1, 1, 0, &targetHue, &targetSaturation, &targetBrightness);
	
	if (saturation < 1e-3)
	{
		hue = targetHue;
		saturation = GRAYSCALE_CAUSTIC_SATURATION;
	}

	if (hue > MIN_RED_THRESHOLD)
	{
		hue -= 1.0;
	}
	else if (hue > MAX_BLUE_THRESHOLD)
	{
		rgb2hsv(1, 0, 1, &targetHue, &targetSaturation, &targetBrightness);
	}

	CGFloat scaledCaustic = CAUSTIC_FRACTION * 0.5 * (1.0 + cos(COSINE_ANGLE_SCALE * M_PI * (hue - targetHue)));

	hsv2rgb(
		hue * (1.0 - scaledCaustic) + targetHue * scaledCaustic,
		saturation,
		brightness * (1.0 - scaledCaustic) + targetBrightness * scaledCaustic,
		&outputComponents[0],
		&outputComponents[1],
		&outputComponents[2]);
	outputComponents[3] = inputComponents[3];
}

void DrawGlossGradientInContext(CGContextRef context, UIColor *color, CGRect inRect)
{
	const CGFloat EXP_COEFFICIENT = 1.2;
	const CGFloat REFLECTION_MAX = 0.70;
	const CGFloat REFLECTION_MIN = 0.30;
	
	GlossParameters params;
	
	params.expCoefficient = EXP_COEFFICIENT;
	params.expOffset = expf(-params.expCoefficient);
	params.expScale = 1.0 / (1.0 - params.expOffset);

	memcpy(
		params.color,
		CGColorGetComponents(color.CGColor),
		sizeof(CGFloat) * 4);
	
	perceptualCausticColorForColor(params.color, params.caustic);
	
	CGFloat glossScale = perceptualGlossFractionForColor(params.color);

	params.initialWhite = glossScale * REFLECTION_MAX;
	params.finalWhite = glossScale * REFLECTION_MIN;

	static const CGFloat input_value_range[2] = {0, 1};
	static const CGFloat output_value_ranges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
	CGFunctionCallbacks callbacks = {0, glossInterpolation, NULL};
	
	CGFunctionRef gradientFunction = CGFunctionCreate(
		(void *)&params,
		1, // number of input values to the callback
		input_value_range,
		4, // number of components (r, g, b, a)
		output_value_ranges,
		&callbacks);
	
	CGPoint startPoint = CGPointMake(CGRectGetMinX(inRect), CGRectGetMinY(inRect));
	CGPoint endPoint = CGPointMake(CGRectGetMinX(inRect), CGRectGetMaxY(inRect));

	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGShadingRef shading = CGShadingCreateAxial(colorspace, startPoint,
		endPoint, gradientFunction, FALSE, FALSE);
	
	CGContextSaveGState(context);
	CGContextClipToRect(context, inRect);
	CGContextDrawShading(context, shading);
	CGContextRestoreGState(context);
	
	CGShadingRelease(shading);
	CGColorSpaceRelease(colorspace);
	CGFunctionRelease(gradientFunction);
}
