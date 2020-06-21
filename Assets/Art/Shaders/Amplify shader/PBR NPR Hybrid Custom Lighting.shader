// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PBR NPR Hybrid CL"
{
	Properties
	{
		_TopTexture1("Top Texture 1", 2D) = "white" {}
		_TexturesCom_BuildingsIndustrial0136_2_M("TexturesCom_BuildingsIndustrial0136_2_M", 2D) = "white" {}
		_CamDepthFadeLength("CamDepthFadeLength", Float) = 0
		_CamDepthFadeOffset("CamDepthFadeOffset", Float) = 0
		_LightGradientIntensity("Light Gradient Intensity", Float) = 0
		_GradientOffset("GradientOffset", Float) = 0
		_GradientScale("GradientScale", Float) = 0
		_PosterizeSteps("PosterizeSteps", Int) = 0
		_GradientKey01("GradientKey01", Color) = (0,0,0,0)
		_GradientKey02("GradientKey02", Color) = (0,0,0,0)
		_SmoothnessMultiplier("SmoothnessMultiplier", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#define ASE_TEXTURE_PARAMS(textureName) textureName

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float eyeDepth;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _TexturesCom_BuildingsIndustrial0136_2_M;
		uniform float4 _TexturesCom_BuildingsIndustrial0136_2_M_ST;
		uniform float _CamDepthFadeLength;
		uniform float _CamDepthFadeOffset;
		uniform float4 _GradientKey01;
		uniform float4 _GradientKey02;
		uniform float _GradientScale;
		uniform float _GradientOffset;
		uniform float _LightGradientIntensity;
		uniform int _PosterizeSteps;
		uniform sampler2D _TopTexture1;
		uniform float _SmoothnessMultiplier;


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1);
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1);
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


		inline float4 TriplanarSamplingSF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			SurfaceOutputStandard s61 = (SurfaceOutputStandard ) 0;
			float2 uv_TexturesCom_BuildingsIndustrial0136_2_M = i.uv_texcoord * _TexturesCom_BuildingsIndustrial0136_2_M_ST.xy + _TexturesCom_BuildingsIndustrial0136_2_M_ST.zw;
			float4 tex2DNode14 = tex2D( _TexturesCom_BuildingsIndustrial0136_2_M, uv_TexturesCom_BuildingsIndustrial0136_2_M );
			float4 color54 = IsGammaSpace() ? float4(0.1132075,0.1132075,0.1132075,0) : float4(0.01219615,0.01219615,0.01219615,0);
			Gradient gradient28 = NewGradient( 1, 2, 2, float4( 0, 0, 0, 0.4735332 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float4 lerpResult50 = lerp( tex2DNode14 , color54 , SampleGradient( gradient28, ase_lightAtten ));
			s61.Albedo = lerpResult50.rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			s61.Normal = ase_worldNormal;
			float cameraDepthFade30 = (( i.eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
			float4 color32 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float3 ase_worldPos = i.worldPos;
			float clampResult64 = clamp( (ase_worldPos.y*_GradientScale + _GradientOffset) , 0.0 , 1.0 );
			float4 lerpResult60 = lerp( _GradientKey01 , _GradientKey02 , clampResult64);
			float4 blendOpSrc33 = ( cameraDepthFade30 * color32 );
			float4 blendOpDest33 = ( SampleGradient( gradient28, ase_lightAtten ) * lerpResult60 * _LightGradientIntensity );
			float4 lerpBlendMode33 = lerp(blendOpDest33,	max( blendOpSrc33, blendOpDest33 ),0.2);
			float div55=256.0/float(_PosterizeSteps);
			float4 posterize55 = ( floor( tex2DNode14 * div55 ) / div55 );
			s61.Emission = ( lerpBlendMode33 * posterize55 ).rgb;
			s61.Metallic = tex2DNode14.r;
			float2 temp_cast_3 = (0.1).xx;
			float2 uv_TexCoord12 = i.uv_texcoord * temp_cast_3;
			float4 triplanar13 = TriplanarSamplingSF( _TopTexture1, ase_worldPos, ase_worldNormal, 1.0, uv_TexCoord12, 1.0, 0 );
			s61.Smoothness = ( triplanar13 * _SmoothnessMultiplier ).x;
			s61.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi61 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g61 = UnityGlossyEnvironmentSetup( s61.Smoothness, data.worldViewDir, s61.Normal, float3(0,0,0));
			gi61 = UnityGlobalIllumination( data, s61.Occlusion, s61.Normal, g61 );
			#endif

			float3 surfResult61 = LightingStandard ( s61, viewDir, gi61 ).rgb;
			surfResult61 += s61.Emission;

			#ifdef UNITY_PASS_FORWARDADD//61
			surfResult61 -= s61.Emission;
			#endif//61
			c.rgb = surfResult61;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.z = customInputData.eyeDepth;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.eyeDepth = IN.customPack1.z;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
-1920;6;1920;1023;4615.403;1178.945;2.480378;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;38;-1400.43,393.0953;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;51;-1432.133,537.3513;Inherit;False;Property;_GradientScale;GradientScale;6;0;Create;True;0;0;False;0;False;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1435.744,598.9799;Inherit;False;Property;_GradientOffset;GradientOffset;5;0;Create;True;0;0;False;0;False;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;45;-1184.186,400.6836;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;64;-979.8101,401.1555;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;62;-1430.868,4.804131;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1147.152,-175.758;Inherit;False;Property;_CamDepthFadeLength;CamDepthFadeLength;2;0;Create;True;0;0;False;0;False;0;120;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;58;-1392.236,689.6553;Inherit;False;Property;_GradientKey01;GradientKey01;8;0;Create;True;0;0;False;0;False;0,0,0,0;0.7264151,0.4905488,0.3118102,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-1144.152,-95.758;Inherit;False;Property;_CamDepthFadeOffset;CamDepthFadeOffset;3;0;Create;True;0;0;False;0;False;0;120.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;28;-1378.515,112.8196;Inherit;False;1;2;2;0,0,0,0.4735332;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.ColorNode;59;-1387.036,887.2553;Inherit;False;Property;_GradientKey02;GradientKey02;9;0;Create;True;0;0;False;0;False;0,0,0,0;0.7547169,0.305907,0.238519,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-550.7559,679.7314;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-798.3358,370.3552;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;32;-887.1691,-50.4659;Inherit;False;Constant;_Color0;Color 0;2;0;Create;True;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientSampleNode;27;-1181.466,178.7951;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-941.6141,565.8528;Inherit;False;Property;_LightGradientIntensity;Light Gradient Intensity;4;0;Create;True;0;0;False;0;False;0;6.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;30;-901.9506,-195.5947;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-523.689,239.3002;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;56;-451.3655,358.3503;Inherit;False;Property;_PosterizeSteps;PosterizeSteps;7;0;Create;True;0;0;False;0;False;0;-126;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-543.16,-155.2812;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-510.555,506.0803;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-610.8683,-372.7058;Inherit;True;Property;_TexturesCom_BuildingsIndustrial0136_2_M;TexturesCom_BuildingsIndustrial0136_2_M;1;0;Create;True;0;0;False;0;False;-1;3a450013f1d3f234da4217a9d03b2a6e;3a450013f1d3f234da4217a9d03b2a6e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;13;-244.4817,400.4478;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;0;Assets/Art/Textures/TexturesCom_BuildingsIndustrial0136_2_M_smoothness.png;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;54;-525.3024,-21.01379;Inherit;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;False;0;False;0.1132075,0.1132075,0.1132075,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosterizeNode;55;-264.3746,272.6663;Inherit;False;1;2;1;COLOR;0,0,0,0;False;0;INT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;33;-171.1215,120.5404;Inherit;False;Lighten;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;66;167.9758,410.8085;Inherit;False;Property;_SmoothnessMultiplier;SmoothnessMultiplier;10;0;Create;True;0;0;False;0;False;0.5;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;172.9758,291.8085;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;50;-49.68987,-2.744319;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;51.63452,162.3503;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;61;238.7235,-4.478607;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;470.2468,-297.6149;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;PBR NPR Hybrid CL;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;45;0;38;2
WireConnection;45;1;51;0
WireConnection;45;2;52;0
WireConnection;64;0;45;0
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;60;2;64;0
WireConnection;27;0;28;0
WireConnection;27;1;62;0
WireConnection;30;0;35;0
WireConnection;30;1;36;0
WireConnection;43;0;27;0
WireConnection;43;1;60;0
WireConnection;43;2;44;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;12;0;11;0
WireConnection;13;3;12;0
WireConnection;55;1;14;0
WireConnection;55;0;56;0
WireConnection;33;0;31;0
WireConnection;33;1;43;0
WireConnection;65;0;13;0
WireConnection;65;1;66;0
WireConnection;50;0;14;0
WireConnection;50;1;54;0
WireConnection;50;2;27;0
WireConnection;57;0;33;0
WireConnection;57;1;55;0
WireConnection;61;0;50;0
WireConnection;61;2;57;0
WireConnection;61;3;14;0
WireConnection;61;4;65;0
WireConnection;0;13;61;0
ASEEND*/
//CHKSM=077E5C1B5D574FC0F305F3EA0D4EAC64185EC0CE