// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SandoTrails"
{
	Properties
	{
		_HighColor("HighColor", Color) = (0,0,0,0)
		_LowColor("Low Color", Color) = (0,0,0,0)
		_SandNormal("SandNormal", 2D) = "bump" {}
		_TrailMap("TrailMap", 2D) = "white" {}
		_SandSpeckCutoff("SandSpeckCutoff", Float) = 0
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_TrailColor("TrailColor", Color) = (0,0,0,0)
		_WaveFrequency("WaveFrequency", Float) = 0
		_WaveFrequencyNoise("WaveFrequencyNoise", Float) = 0
		_WaveNoiseScale("WaveNoiseScale", Float) = 0
		_WaveLengthNoise("WaveLengthNoise", Float) = 0
		_WaveAmplitude("WaveAmplitude", Float) = 1.2
		_GradientScale("GradientScale", Float) = 0.17
		_GradientOffset("GradientOffset", Float) = 0
		_InternalNoiseScale("InternalNoiseScale", Float) = 0.3
		_NormalScale("NormalScale", Float) = 0
		_NormalStrength("Normal Strength", Float) = 0
		_Smoothness("Smoothness", Float) = 0
		_Metalness("Metalness", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry-100" }
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
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _SandNormal;
		uniform float _NormalScale;
		uniform float _NormalStrength;
		uniform float4 _LowColor;
		uniform float4 _HighColor;
		uniform float _GradientScale;
		uniform float _GradientOffset;
		uniform float _WaveFrequency;
		uniform float _WaveFrequencyNoise;
		uniform float _WaveNoiseScale;
		uniform float _WaveLengthNoise;
		uniform float _WaveAmplitude;
		uniform float _InternalNoiseScale;
		uniform float4 _TrailColor;
		uniform sampler2D _TrailMap;
		uniform float4 _TrailMap_ST;
		uniform float _SandSpeckCutoff;
		uniform float4 _FresnelColor;
		uniform float _Metalness;
		uniform float _Smoothness;


		float2 unity_gradientNoise_dir( float2 p )
		{
			p = p % 289;
			float x = (34 * p.x + 1) * p.x % 289 + p.y;
			x = (34 * x + 1) * x % 289;
			x = frac(x / 41) * 2 - 1;
			return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
		}


		float unity_gradientNoise( float2 p )
		{
			float2 ip = floor(p);
			float2 fp = frac(p);
			float d00 = dot(unity_gradientNoise_dir(ip), fp);
			float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
			float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
			float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
			fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
			return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
		}


		float Unity_GradientNoise_float54_g3( float2 UV , float Scale )
		{
			return unity_gradientNoise(UV * Scale) + 0.5;
		}


		float Unity_GradientNoise_float54_g4( float2 UV , float Scale )
		{
			return unity_gradientNoise(UV * Scale) + 0.5;
		}


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float localCalculateTangentsStandard16_g7 = ( 0.0 );
			v.tangent.xyz = cross ( v.normal, float3( 0, 0, 1 ) );
			v.tangent.w = -1;
			v.vertex.xyz += localCalculateTangentsStandard16_g7;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_NormalScale).xx;
			float2 uv_TexCoord28 = i.uv_texcoord * temp_cast_0;
			float2 temp_output_2_0_g6 = uv_TexCoord28;
			float2 break6_g6 = temp_output_2_0_g6;
			float temp_output_25_0_g6 = ( pow( 0.5 , 3.0 ) * 0.1 );
			float2 appendResult8_g6 = (float2(( break6_g6.x + temp_output_25_0_g6 ) , break6_g6.y));
			float4 tex2DNode14_g6 = tex2D( _SandNormal, temp_output_2_0_g6 );
			float temp_output_4_0_g6 = _NormalStrength;
			float3 appendResult13_g6 = (float3(1.0 , 0.0 , ( ( tex2D( _SandNormal, appendResult8_g6 ).g - tex2DNode14_g6.g ) * temp_output_4_0_g6 )));
			float2 appendResult9_g6 = (float2(break6_g6.x , ( break6_g6.y + temp_output_25_0_g6 )));
			float3 appendResult16_g6 = (float3(0.0 , 1.0 , ( ( tex2D( _SandNormal, appendResult9_g6 ).g - tex2DNode14_g6.g ) * temp_output_4_0_g6 )));
			float3 normalizeResult22_g6 = normalize( cross( appendResult13_g6 , appendResult16_g6 ) );
			o.Normal = normalizeResult22_g6;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult79 = (float2(_WaveFrequencyNoise , _WaveNoiseScale));
			float2 uv_TexCoord8 = i.uv_texcoord * appendResult79;
			float2 UV54_g3 = uv_TexCoord8;
			float Scale54_g3 = _WaveLengthNoise;
			float localUnity_GradientNoise_float54_g3 = Unity_GradientNoise_float54_g3( UV54_g3 , Scale54_g3 );
			float2 temp_cast_1 = (( ( ( 1.0 - abs( ( ase_worldPos.x * _WaveFrequency ) ) ) + ( localUnity_GradientNoise_float54_g3 * ( _WaveAmplitude / 100.0 ) ) ) % 2.53 )).xx;
			float2 UV54_g4 = temp_cast_1;
			float Scale54_g4 = _InternalNoiseScale;
			float localUnity_GradientNoise_float54_g4 = Unity_GradientNoise_float54_g4( UV54_g4 , Scale54_g4 );
			float temp_output_21_0 = ( (ase_worldPos.y*_GradientScale + _GradientOffset) * localUnity_GradientNoise_float54_g4 );
			float4 lerpResult107 = lerp( _LowColor , _HighColor , saturate( temp_output_21_0 ));
			float4 MainColor133 = lerpResult107;
			float2 uv_TrailMap = i.uv_texcoord * _TrailMap_ST.xy + _TrailMap_ST.zw;
			float4 tex2DNode128 = tex2D( _TrailMap, uv_TrailMap );
			float4 appendResult129 = (float4(tex2DNode128.r , tex2DNode128.g , tex2DNode128.b , 0.0));
			float4 lerpResult135 = lerp( MainColor133 , _TrailColor , appendResult129);
			float4 FinalColor136 = lerpResult135;
			Gradient gradient97 = NewGradient( 0, 2, 2, float4( 0, 0, 0, 0.9823605 ), float4( 0.6415094, 0.4862079, 0.3056248, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0.7499962 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV102 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode102 = ( 0.0 + 0.78 * pow( max( 1.0 - fresnelNdotV102 , 0.0001 ), 6.34 ) );
			o.Albedo = ( FinalColor136 + SampleGradient( gradient97, ( 0.0 * _SandSpeckCutoff * ( 1.0 - temp_output_21_0 ) ) ) + ( fresnelNode102 * _FresnelColor ) ).xyz;
			o.Metallic = _Metalness;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}

	Dependency "BaseMapShader"="ASESampleShaders/SimpleTerrainBase"
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
32.66667;184.6667;2244;1191;2369.144;-1178.452;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;100;-2428.164,-413.7786;Inherit;False;2178.117;789.3458;Waves;24;72;15;75;80;79;2;81;82;8;18;12;19;14;17;74;73;71;9;21;5;7;11;102;103;Waves;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2378.165,-5.726933;Inherit;False;Property;_WaveFrequencyNoise;WaveFrequencyNoise;27;0;Create;True;0;0;False;0;False;0;7.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2353.164,70.27318;Inherit;False;Property;_WaveNoiseScale;WaveNoiseScale;28;0;Create;True;0;0;False;0;False;0;5.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-1862.826,-363.7786;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;79;-2137.165,3.273098;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-1927.165,-86.727;Inherit;False;Property;_WaveFrequency;WaveFrequency;26;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1881.887,259.5672;Inherit;False;Property;_WaveAmplitude;WaveAmplitude;30;0;Create;True;0;0;False;0;False;1.2;196;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1962.929,-4.492405;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1727.478,-182.5501;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1914.567,158.1214;Inherit;False;Property;_WaveLengthNoise;WaveLengthNoise;29;0;Create;True;0;0;False;0;False;0;31.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-1681.848,147.8443;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;18;-1658.597,-71.12019;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;12;-1728.148,0.6333885;Inherit;False;GradientNoise;-1;;3;73bcad20642e36b47bcbf1cdbeca1c3f;0;2;2;FLOAT2;0,0;False;3;FLOAT;120;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1494.062,0.2548027;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-1511.597,-72.1202;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-1337.281,-71.8142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;9;-1212.883,-71.89741;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2.53;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1218.165,-244.7269;Inherit;False;Property;_GradientScale;GradientScale;31;0;Create;True;0;0;False;0;False;0.17;0.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1257.483,21.46951;Inherit;False;Property;_InternalNoiseScale;InternalNoiseScale;33;0;Create;True;0;0;False;0;False;0.3;0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1221.791,-142.3781;Inherit;False;Property;_GradientOffset;GradientOffset;32;0;Create;True;0;0;False;0;False;0;0.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;7;-1002.854,-87.26049;Inherit;False;GradientNoise;-1;;4;73bcad20642e36b47bcbf1cdbeca1c3f;0;2;2;FLOAT2;0,0;False;3;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;5;-1002.582,-219.6884;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.17;False;2;FLOAT;0.16;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-766.7944,-117.7625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;126;-798.8429,-571.5288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;108;-785.7474,-1031.403;Inherit;False;Property;_LowColor;Low Color;19;0;Create;True;0;0;False;0;False;0,0,0,0;0.1918365,0.09420606,0.2735848,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;110;-977.7474,-797.403;Inherit;False;Property;_HighColor;HighColor;18;0;Create;True;0;0;False;0;False;0,0,0,0;0.3884339,0.3884339,0.4759999,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;127;-1975.241,1583.646;Inherit;True;Property;_TrailMap;TrailMap;21;0;Create;True;0;0;False;0;False;None;fc184eb6607beb14699241c6ff2a7816;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;107;-506.6475,-663.803;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;128;-1724.963,1580.221;Inherit;True;Property;_TextureSample0;Texture Sample 0;21;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;133;-198.3405,-621.265;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-1264.417,1293.203;Inherit;False;133;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;132;-1300.101,1419.196;Inherit;False;Property;_TrailColor;TrailColor;24;0;Create;True;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;99;-1913.826,539.2788;Inherit;False;1108.883;399.5045;Specks;7;84;87;97;95;96;92;91;Specks;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;129;-1289.563,1656.421;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldNormalVector;103;-826.8598,173.9363;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;104;-807.6597,309.9362;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;98;-1024,416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;135;-947.9863,1607.563;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1579.971,822.7834;Inherit;False;Property;_SandSpeckCutoff;SandSpeckCutoff;22;0;Create;True;0;0;False;0;False;0;2.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-750.5183,1658.758;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;97;-1380.151,589.2789;Inherit;False;0;2;2;0,0,0,0.9823605;0.6415094,0.4862079,0.3056248,1;1,0.7499962;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-1368.537,668.4299;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;102;-630.0602,159.5363;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.78;False;3;FLOAT;6.34;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;106;-508.4599,538.7363;Inherit;False;Property;_FresnelColor;FresnelColor;23;0;Create;True;0;0;False;0;False;0,0,0,0;0.8654932,0.5814346,0.8867924,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;-679.2169,812.5726;Inherit;False;Property;_NormalScale;NormalScale;34;0;Create;True;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-343.6599,375.5361;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;67;-506.0598,916.7762;Inherit;True;Property;_SandNormal;SandNormal;20;0;Create;True;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-207.482,95.4707;Inherit;False;136;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-514.7996,794.7148;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;12.73,15.73;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-468.5592,1111.279;Inherit;False;Property;_NormalStrength;Normal Strength;35;0;Create;True;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;96;-1133.943,641.8719;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;66;-230.1848,922.2377;Inherit;False;NormalCreate;36;;6;e12f7ae19d416b942820e3932b56220f;0;4;1;SAMPLER2D;;False;2;FLOAT2;0,0;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-10.8875,108.6694;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-198.1579,409.501;Inherit;False;Property;_Smoothness;Smoothness;38;0;Create;True;0;0;False;0;False;0;0.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-190.6571,484.2103;Inherit;False;Property;_Metalness;Metalness;39;0;Create;True;0;0;False;0;False;0;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;87;-1604.004,611.9677;Inherit;True;SimpleNoise;-1;;5;ef01ab937cd02e948a861896994169e3;0;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-1863.826,605.6321;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;1;14.69754,407.4135;Inherit;False;Four Splats First Pass Terrain;0;;7;37452fdfb732e1443b7e39720d05b708;0;6;59;FLOAT4;0,0,0,0;False;60;FLOAT4;0,0,0,0;False;61;FLOAT3;0,0,0;False;57;FLOAT;0;False;58;FLOAT;0;False;62;FLOAT;0;False;6;FLOAT4;0;FLOAT3;14;FLOAT;56;FLOAT;45;FLOAT;19;FLOAT3;17
Node;AmplifyShaderEditor.PosVertexDataNode;139;-2168.294,2032.708;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-1900.243,2013.888;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;144;-1685.9,2014.864;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.MVPMatrixNode;138;-2182.75,2209.432;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-1828.172,806.6838;Inherit;False;Property;_SandSpeckScale;SandSpeckScale;25;0;Create;True;0;0;False;0;False;0;1200000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;427.5953,110.7223;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;SandoTrails;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;-100;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;1;BaseMapShader=ASESampleShaders/SimpleTerrainBase;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;79;0;80;0
WireConnection;79;1;75;0
WireConnection;8;0;79;0
WireConnection;82;0;2;1
WireConnection;82;1;81;0
WireConnection;15;0;11;0
WireConnection;18;0;82;0
WireConnection;12;2;8;0
WireConnection;12;3;72;0
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;19;0;18;0
WireConnection;17;0;19;0
WireConnection;17;1;14;0
WireConnection;9;0;17;0
WireConnection;7;2;9;0
WireConnection;7;3;71;0
WireConnection;5;0;2;2
WireConnection;5;1;74;0
WireConnection;5;2;73;0
WireConnection;21;0;5;0
WireConnection;21;1;7;0
WireConnection;126;0;21;0
WireConnection;107;0;108;0
WireConnection;107;1;110;0
WireConnection;107;2;126;0
WireConnection;128;0;127;0
WireConnection;133;0;107;0
WireConnection;129;0;128;1
WireConnection;129;1;128;2
WireConnection;129;2;128;3
WireConnection;98;0;21;0
WireConnection;135;0;134;0
WireConnection;135;1;132;0
WireConnection;135;2;129;0
WireConnection;136;0;135;0
WireConnection;95;1;91;0
WireConnection;95;2;98;0
WireConnection;102;0;103;0
WireConnection;102;4;104;0
WireConnection;105;0;102;0
WireConnection;105;1;106;0
WireConnection;28;0;68;0
WireConnection;96;0;97;0
WireConnection;96;1;95;0
WireConnection;66;1;67;0
WireConnection;66;2;28;0
WireConnection;66;4;32;0
WireConnection;56;0;137;0
WireConnection;56;1;96;0
WireConnection;56;2;105;0
WireConnection;1;60;56;0
WireConnection;1;61;66;0
WireConnection;1;57;22;0
WireConnection;1;58;30;0
WireConnection;140;0;139;0
WireConnection;140;1;138;0
WireConnection;144;0;140;0
WireConnection;0;0;1;0
WireConnection;0;1;1;14
WireConnection;0;3;1;56
WireConnection;0;4;1;45
WireConnection;0;11;1;17
ASEEND*/
//CHKSM=4A3097E54A58F914F525F10383A435FDABA38863