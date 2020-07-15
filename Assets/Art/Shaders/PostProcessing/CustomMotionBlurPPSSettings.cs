// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( CustomMotionBlurPPSRenderer ), PostProcessEvent.AfterStack, "CustomMotionBlur", true )]
public sealed class CustomMotionBlurPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "NoiseScale" )]
	public FloatParameter _NoiseScale = new FloatParameter { value = 17.28066f };
	[Tooltip( "MaskRadius" )]
	public FloatParameter _MaskRadius = new FloatParameter { value = 0f };
}

public sealed class CustomMotionBlurPPSRenderer : PostProcessEffectRenderer<CustomMotionBlurPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "CustomMotionBlur" ) );
		sheet.properties.SetFloat( "_NoiseScale", settings._NoiseScale );
		sheet.properties.SetFloat( "_MaskRadius", settings._MaskRadius );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
