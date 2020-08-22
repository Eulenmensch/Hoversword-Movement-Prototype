// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tunnel Tiles NPR Hybrid"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_NormalStrength("Normal Strength", Float) = 1
		_Smoothness("Smoothness", Float) = 1
		_ShadowColor1("Shadow Color", Color) = (0.1132075,0.1132075,0.1132075,0)
		_GradientKey2("GradientKey01", Color) = (0,0,0,0)
		_GradientKey3("GradientKey02", Color) = (0,0,0,0)
		_LightGradientIntensity1("Light Gradient Intensity", Float) = 0
		_LightGradientOffset1("Light Gradient Offset", Float) = 0
		_LightGradientScale1("Light Gradient Scale", Float) = 0
		_PosterizeSteps1("PosterizeSteps", Int) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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

		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _ShadowColor1;
		uniform float _NormalStrength;
		uniform int _PosterizeSteps1;
		uniform float4 _GradientKey2;
		uniform float4 _GradientKey3;
		uniform float _LightGradientScale1;
		uniform float _LightGradientOffset1;
		uniform float _LightGradientIntensity1;
		uniform float _Smoothness;


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
			SurfaceOutputStandard s44 = (SurfaceOutputStandard ) 0;
			Gradient gradient9 = NewGradient( 0, 3, 2, float4( 0.5176471, 0.4287059, 0.3364706, 0 ), float4( 0.8913294, 0.9372549, 0.9359041, 0.2514382 ), float4( 0.8913294, 0.9372549, 0.9359041, 0.3808194 ), 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTexture, uv_MainTexture );
			float4 temp_cast_0 = (tex2DNode1.r).xxxx;
			float4 blendOpSrc10 = SampleGradient( gradient9, tex2DNode1.r );
			float4 blendOpDest10 = temp_cast_0;
			float4 Albedo15 = ( saturate( (( blendOpDest10 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest10 ) * ( 1.0 - blendOpSrc10 ) ) : ( 2.0 * blendOpDest10 * blendOpSrc10 ) ) ));
			Gradient gradient26 = NewGradient( 1, 2, 2, float4( 0, 0, 0, 0.4735332 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float4 LightAttenuationGradient32 = SampleGradient( gradient26, ase_lightAtten );
			float4 lerpResult48 = lerp( Albedo15 , _ShadowColor1 , LightAttenuationGradient32);
			s44.Albedo = lerpResult48.rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 temp_output_16_0_g1 = ( ase_worldPos * 100.0 );
			float3 crossY18_g1 = cross( ase_worldNormal , ddy( temp_output_16_0_g1 ) );
			float3 worldDerivativeX2_g1 = ddx( temp_output_16_0_g1 );
			float dotResult6_g1 = dot( crossY18_g1 , worldDerivativeX2_g1 );
			float crossYDotWorldDerivX34_g1 = abs( dotResult6_g1 );
			float temp_output_20_0_g1 = ( tex2DNode1.b * _NormalStrength );
			float3 crossX19_g1 = cross( ase_worldNormal , worldDerivativeX2_g1 );
			float3 break29_g1 = ( sign( crossYDotWorldDerivX34_g1 ) * ( ( ddx( temp_output_20_0_g1 ) * crossY18_g1 ) + ( ddy( temp_output_20_0_g1 ) * crossX19_g1 ) ) );
			float3 appendResult30_g1 = (float3(break29_g1.x , -break29_g1.y , break29_g1.z));
			float3 normalizeResult39_g1 = normalize( ( ( crossYDotWorldDerivX34_g1 * ase_worldNormal ) - appendResult30_g1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g1 = mul( ase_worldToTangent, normalizeResult39_g1);
			float3 Normals17 = worldToTangentDir42_g1;
			s44.Normal = WorldNormalVector( i , Normals17 );
			float div41=256.0/float(_PosterizeSteps1);
			float4 posterize41 = ( floor( Albedo15 * div41 ) / div41 );
			float4 lerpResult34 = lerp( _GradientKey2 , _GradientKey3 , saturate( (ase_worldPos.y*_LightGradientScale1 + _LightGradientOffset1) ));
			float4 NPREmissive43 = ( posterize41 * ( LightAttenuationGradient32 * lerpResult34 * _LightGradientIntensity1 ) );
			s44.Emission = NPREmissive43.rgb;
			s44.Metallic = 0.0;
			float Smoothness13 = ( 1.0 - ( tex2DNode1.g * _Smoothness ) );
			s44.Smoothness = Smoothness13;
			s44.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi44 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g44 = UnityGlossyEnvironmentSetup( s44.Smoothness, data.worldViewDir, s44.Normal, float3(0,0,0));
			gi44 = UnityGlobalIllumination( data, s44.Occlusion, s44.Normal, g44 );
			#endif

			float3 surfResult44 = LightingStandard ( s44, viewDir, gi44 ).rgb;
			surfResult44 += s44.Emission;

			#ifdef UNITY_PASS_FORWARDADD//44
			surfResult44 -= s44.Emission;
			#endif//44
			c.rgb = surfResult44;
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
				float2 customPack1 : TEXCOORD1;
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
-1921;-1;1922;1031;3609.25;1034.65;3.599787;True;False
Node;AmplifyShaderEditor.CommentaryNode;20;-1666,-562;Inherit;False;1378;729;PBR;14;7;1;3;6;2;5;4;10;12;9;8;15;13;17;PBR;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;7;-1616,-256;Inherit;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;False;0;False;714974d831a7a8c468e7e2a80bf7466d;714974d831a7a8c468e7e2a80bf7466d;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1664,304;Inherit;False;802;275;Light Gradient;4;32;29;26;25;Light Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-1664,704;Inherit;False;1682;662;NPR;16;43;42;41;39;38;37;36;35;34;33;31;30;28;27;24;23;NPR;1,1,1,1;0;0
Node;AmplifyShaderEditor.GradientNode;9;-1264,-512;Inherit;False;0;3;2;0.5176471,0.4287059,0.3364706,0;0.8913294,0.9372549,0.9359041,0.2514382;0.8913294,0.9372549,0.9359041,0.3808194;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1392,-256;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-1616,1264;Inherit;False;Property;_LightGradientOffset1;Light Gradient Offset;7;0;Create;True;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;8;-1040,-432;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;23;-1616,1040;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightAttenuation;25;-1616,432;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1616,1184;Inherit;False;Property;_LightGradientScale1;Light Gradient Scale;8;0;Create;True;0;0;False;0;False;0;0.007;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;26;-1616,352;Inherit;False;1;2;2;0,0,0,0.4735332;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GradientSampleNode;29;-1408,352;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;10;-704,-256;Inherit;False;Overlay;True;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;28;-1360,1120;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-512,-256;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;33;-1360,768;Inherit;False;Property;_GradientKey2;GradientKey01;4;0;Create;True;0;0;False;0;False;0,0,0,0;0.8018868,0.3290762,0.3290762,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;31;-1184,1120;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;30;-1360,944;Inherit;False;Property;_GradientKey3;GradientKey02;5;0;Create;True;0;0;False;0;False;0,0,0,0;0.509434,0.4515965,0.3820755,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1101.338,398.6812;Inherit;False;LightAttenuationGradient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-1008,992;Inherit;False;32;LightAttenuationGradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-800,816;Inherit;False;15;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;34;-1008,1072;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;39;-800,896;Inherit;False;Property;_PosterizeSteps1;PosterizeSteps;9;0;Create;True;0;0;False;0;False;0;29;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1072,-64;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;False;0;False;1;0.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1264,32;Inherit;False;Property;_NormalStrength;Normal Strength;1;0;Create;True;0;0;False;0;False;1;14.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1008,1200;Inherit;False;Property;_LightGradientIntensity1;Light Gradient Intensity;6;0;Create;True;0;0;False;0;False;0;1.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-736,1072;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-1056,32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-928,-144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;41;-560,976;Inherit;False;1;2;1;COLOR;0,0,0,0;False;0;INT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-336,1072;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;4;-928,32;Inherit;False;Normal From Height;-1;;1;1942fe2c5f1a1f94881a33d532e4afeb;0;1;20;FLOAT;0;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;12;-784,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-208,1072;Inherit;False;NPREmissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-624,-128;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;-192,-80;Inherit;False;Property;_ShadowColor1;Shadow Color;3;0;Create;True;0;0;False;0;False;0.1132075,0.1132075,0.1132075,0;0.5754716,0.5076095,0.5076095,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;47;-192,-160;Inherit;False;15;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-192,96;Inherit;False;32;LightAttenuationGradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-672,32;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;112,192;Inherit;False;13;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;112,32;Inherit;False;17;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;112,112;Inherit;False;43;NPREmissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;48;112,-96;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;44;400,-48;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;720,-48;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Tunnel Tiles NPR Hybrid;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;0;7;0
WireConnection;8;0;9;0
WireConnection;8;1;1;1
WireConnection;29;0;26;0
WireConnection;29;1;25;0
WireConnection;10;0;8;0
WireConnection;10;1;1;1
WireConnection;28;0;23;2
WireConnection;28;1;24;0
WireConnection;28;2;27;0
WireConnection;15;0;10;0
WireConnection;31;0;28;0
WireConnection;32;0;29;0
WireConnection;34;0;33;0
WireConnection;34;1;30;0
WireConnection;34;2;31;0
WireConnection;37;0;36;0
WireConnection;37;1;34;0
WireConnection;37;2;35;0
WireConnection;2;0;1;3
WireConnection;2;1;3;0
WireConnection;5;0;1;2
WireConnection;5;1;6;0
WireConnection;41;1;38;0
WireConnection;41;0;39;0
WireConnection;42;0;41;0
WireConnection;42;1;37;0
WireConnection;4;20;2;0
WireConnection;12;0;5;0
WireConnection;43;0;42;0
WireConnection;13;0;12;0
WireConnection;17;0;4;40
WireConnection;48;0;47;0
WireConnection;48;1;45;0
WireConnection;48;2;46;0
WireConnection;44;0;48;0
WireConnection;44;1;18;0
WireConnection;44;2;49;0
WireConnection;44;4;14;0
WireConnection;0;13;44;0
ASEEND*/
//CHKSM=B4F96A31566A364F7E9DB7141E78EC02105D53E3