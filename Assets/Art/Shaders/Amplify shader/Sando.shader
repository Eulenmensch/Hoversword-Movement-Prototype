// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Sando"
{
	Properties
	{
		_SandNormal("SandNormal", 2D) = "bump" {}
		_SandSpeckCutoff("SandSpeckCutoff", Float) = 0
		_SparkleNoise("SparkleNoise", 2D) = "white" {}
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_SandSpeckScale("SandSpeckScale", Float) = 0
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
		_SparkleTiling("SparkleTiling", Float) = 0
		_SparkleCutoff("SparkleCutoff", Float) = 0
		_SparklesIntensity("SparklesIntensity", Float) = 0
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
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _SandNormal;
		uniform float _NormalScale;
		uniform float _NormalStrength;
		uniform float _GradientScale;
		uniform float _GradientOffset;
		uniform float _WaveFrequency;
		uniform float _WaveFrequencyNoise;
		uniform float _WaveNoiseScale;
		uniform float _WaveLengthNoise;
		uniform float _WaveAmplitude;
		uniform float _InternalNoiseScale;
		uniform sampler2D _SparkleNoise;
		uniform float _SparkleTiling;
		uniform float _SparkleCutoff;
		uniform float _SparklesIntensity;
		uniform float _SandSpeckScale;
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


		float unity_noise_randomValue( float2 uv )
		{
			return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
		}


		float unity_noise_interpolate( float a , float b , float t )
		{
			return (1.0-t)*a + (t*b);
		}


		float unity_valueNoise( float2 uv )
		{
			float2 i = floor(uv);
			    float2 f = frac(uv);
			    f = f * f * (3.0 - 2.0 * f);
			    uv = abs(frac(uv) - 0.5);
			    float2 c0 = i + float2(0.0, 0.0);
			    float2 c1 = i + float2(1.0, 0.0);
			    float2 c2 = i + float2(0.0, 1.0);
			    float2 c3 = i + float2(1.0, 1.0);
			    float r0 = unity_noise_randomValue(c0);
			    float r1 = unity_noise_randomValue(c1);
			    float r2 = unity_noise_randomValue(c2);
			    float r3 = unity_noise_randomValue(c3);
			    float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
			    float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
			    float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
			    return t;
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


		float Unity_GradientNoise_float54_g3( float2 UV , float Scale )
		{
			return unity_gradientNoise(UV * Scale) + 0.5;
		}


		float Unity_GradientNoise_float54_g4( float2 UV , float Scale )
		{
			return unity_gradientNoise(UV * Scale) + 0.5;
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
			Gradient gradient4 = NewGradient( 0, 3, 2, float4( 0.8301887, 0.7892306, 0.5991456, 0 ), float4( 0.9150943, 0.548407, 0.2978373, 0.5000076 ), float4( 0.6698113, 0.3165442, 0.1737718, 1 ), 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
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
			float2 temp_cast_2 = (_SparkleTiling).xx;
			float2 uv_TexCoord35 = i.uv_texcoord * temp_cast_2;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float dotResult60 = dot( ase_worldViewDir , (WorldNormalVector( i , ase_vertexNormal )) );
			float4 triplanar45 = TriplanarSamplingSF( _SparkleNoise, ase_worldPos, ase_worldNormal, 4.54, _SparkleTiling, 1.0, 0 );
			float Sparkles52 = ( ( 1.0 - step( ( tex2D( _SparkleNoise, ( uv_TexCoord35 * dotResult60 ) ).r * triplanar45.x ) , _SparkleCutoff ) ) * _SparklesIntensity );
			Gradient gradient97 = NewGradient( 0, 2, 2, float4( 0, 0, 0, 0.9823605 ), float4( 0.6415094, 0.4862079, 0.3056248, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0.7499962 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float localUnity_SimpleNoise_float4_g5 = ( 0.0 );
			float2 UV4_g5 = i.uv_texcoord;
			float3 temp_cast_3 = (_SandSpeckScale).xxx;
			float3 Scale4_g5 = temp_cast_3;
			float Out4_g5 = 0;
			{
			float t = 0.0;
			    float freq = pow(2.0, float(0));
			    float amp = pow(0.5, float(3-0));
			    t += unity_valueNoise(float2(UV4_g5.x*Scale4_g5.x/freq, UV4_g5.y*Scale4_g5.x/freq))*amp;
			    freq = pow(2.0, float(1));
			    amp = pow(0.5, float(3-1));
			    t += unity_valueNoise(float2(UV4_g5.x*Scale4_g5.y/freq, UV4_g5.y*Scale4_g5.y/freq))*amp;
			    freq = pow(2.0, float(2));
			    amp = pow(0.5, float(3-2));
			    t += unity_valueNoise(float2(UV4_g5.x*Scale4_g5.z/freq, UV4_g5.y*Scale4_g5.z/freq))*amp;
			    Out4_g5 = t;
			}
			float fresnelNdotV102 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode102 = ( 0.0 + 0.78 * pow( max( 1.0 - fresnelNdotV102 , 0.0001 ), 6.34 ) );
			o.Albedo = ( SampleGradient( gradient4, temp_output_21_0 ) + Sparkles52 + SampleGradient( gradient97, ( Out4_g5 * _SandSpeckCutoff * ( 1.0 - temp_output_21_0 ) ) ) + ( fresnelNode102 * _FresnelColor ) ).xyz;
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
-1920;6;1920;1023;2690.86;606.8637;1.6;True;False
Node;AmplifyShaderEditor.CommentaryNode;86;-2282.646,1336.338;Inherit;False;1977.029;691.4705;Sparkles;24;58;59;61;34;35;36;38;40;39;42;43;41;45;44;47;46;48;49;50;54;51;53;52;60;Sparkles;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1707.745,1408.002;Float;False;Property;_SparkleTiling;SparkleTiling;33;0;Create;True;0;0;False;0;False;0;13.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;59;-2232.646,1655.564;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1489.321,1386.338;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;100;-2415.364,-442.5786;Inherit;False;2178.117;789.3458;Waves;26;72;15;75;80;79;2;81;82;8;18;12;19;14;17;74;73;71;9;3;21;4;5;7;11;102;103;Waves;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;58;-2041.846,1468.764;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;61;-2045.997,1635.743;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;36;-1270.732,1466.807;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2340.364,41.47318;Inherit;False;Property;_WaveNoiseScale;WaveNoiseScale;25;0;Create;True;0;0;False;0;False;0;5.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2365.365,-34.52694;Inherit;False;Property;_WaveFrequencyNoise;WaveFrequencyNoise;24;0;Create;True;0;0;False;0;False;0;7.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;38;-1479.725,1504.238;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;60;-1675.382,1543.631;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1456.893,1545.672;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;39;-1689.615,1692.731;Float;True;Property;_SparkleNoise;SparkleNoise;20;0;Create;True;0;0;False;0;False;None;8d7ad3e5fa929b640b6b80438a2a3c40;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-1850.026,-392.5786;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;79;-2124.365,-25.52691;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-1914.365,-115.527;Inherit;False;Property;_WaveFrequency;WaveFrequency;23;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1869.087,230.7672;Inherit;False;Property;_WaveAmplitude;WaveAmplitude;27;0;Create;True;0;0;False;0;False;1.2;196;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1901.767,129.3214;Inherit;False;Property;_WaveLengthNoise;WaveLengthNoise;26;0;Create;True;0;0;False;0;False;0;31.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1714.678,-211.35;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1950.129,-33.29242;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;43;-1236.42,1565.064;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1674.242,1911.808;Float;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;4.54;24.97;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;42;-1250.456,1512.036;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TriplanarNode;45;-1377.78,1759.977;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;0;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Sparkle;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-1669.048,119.0443;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;44;-1172.027,1391.993;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;18;-1645.797,-99.92018;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;12;-1715.348,-28.16662;Inherit;False;GradientNoise;-1;;3;73bcad20642e36b47bcbf1cdbeca1c3f;0;2;2;FLOAT2;0,0;False;3;FLOAT;120;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-862.564,1432.693;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-1089.579,1594.765;Float;False;Property;_SparkleCutoff;SparkleCutoff;34;0;Create;True;0;0;False;0;False;0;1.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-1498.797,-100.9202;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1481.262,-28.54521;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-1324.481,-100.6142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;48;-695.6711,1422.566;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;-552.2502,1427.697;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1208.991,-171.1781;Inherit;False;Property;_GradientOffset;GradientOffset;29;0;Create;True;0;0;False;0;False;0;0.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;9;-1200.083,-100.6974;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2.53;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1205.365,-273.5269;Inherit;False;Property;_GradientScale;GradientScale;28;0;Create;True;0;0;False;0;False;0.17;0.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1244.683,-7.330505;Inherit;False;Property;_InternalNoiseScale;InternalNoiseScale;30;0;Create;True;0;0;False;0;False;0.3;0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;5;-989.7823,-248.4884;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.17;False;2;FLOAT;0.16;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;7;-990.0544,-116.0605;Inherit;False;GradientNoise;-1;;4;73bcad20642e36b47bcbf1cdbeca1c3f;0;2;2;FLOAT2;0,0;False;3;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;50;-417.9293,1519.984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;99;-1913.826,539.2788;Inherit;False;1108.883;399.5045;Specks;7;84;87;97;95;96;92;91;Specks;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-927.6924,1689.947;Float;False;Property;_SparklesIntensity;SparklesIntensity;35;0;Create;True;0;0;False;0;False;0;2.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-1828.172,806.6838;Inherit;False;Property;_SandSpeckScale;SandSpeckScale;22;0;Create;True;0;0;False;0;False;0;1200000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-753.9945,-146.5625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-1863.826,605.6321;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;51;-747.3442,1560.047;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;104;-807.6597,309.9362;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;91;-1579.971,822.7834;Inherit;False;Property;_SandSpeckCutoff;SandSpeckCutoff;19;0;Create;True;0;0;False;0;False;0;2.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;103;-814.0599,145.1363;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-710.5291,1595.878;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;98;-1024,416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;87;-1627.004,609.9677;Inherit;True;SimpleNoise;-1;;5;ef01ab937cd02e948a861896994169e3;0;2;5;FLOAT2;0,0;False;6;FLOAT3;28.32,19.85,15.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;4;-786.9147,-241.9095;Inherit;False;0;3;2;0.8301887,0.7892306,0.5991456,0;0.9150943,0.548407,0.2978373,0.5000076;0.6698113,0.3165442,0.1737718,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-529.6172,1609.275;Float;False;Sparkles;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;102;-617.2603,130.7363;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.78;False;3;FLOAT;6.34;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-679.2169,812.5726;Inherit;False;Property;_NormalScale;NormalScale;31;0;Create;True;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-1368.537,668.4299;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;106;-508.4599,538.7363;Inherit;False;Property;_FresnelColor;FresnelColor;21;0;Create;True;0;0;False;0;False;0,0,0,0;0.9622642,0.8016171,0.521983,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientNode;97;-1380.151,589.2789;Inherit;False;0;2;2;0,0,0,0.9823605;0.6415094,0.4862079,0.3056248,1;1,0.7499962;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-514.7996,794.7148;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;12.73,15.73;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;55;-235.2374,254.6718;Inherit;False;52;Sparkles;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;96;-1133.943,641.8719;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;67;-506.0598,916.7762;Inherit;True;Property;_SandNormal;SandNormal;18;0;Create;True;0;0;False;0;False;None;4769e995b8ae8f14dbcb4d9eeef57a09;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-343.6599,375.5361;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-468.5592,1111.279;Inherit;False;Property;_NormalStrength;Normal Strength;32;0;Create;True;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;3;-566.2476,-139.7182;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;66;-230.1848,922.2377;Inherit;False;NormalCreate;36;;6;e12f7ae19d416b942820e3932b56220f;0;4;1;SAMPLER2D;;False;2;FLOAT2;0,0;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-184.5861,110.4978;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-198.1579,409.501;Inherit;False;Property;_Smoothness;Smoothness;38;0;Create;True;0;0;False;0;False;0;0.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-190.6571,484.2103;Inherit;False;Property;_Metalness;Metalness;39;0;Create;True;0;0;False;0;False;0;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;101;-1052.877,1135.212;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1;14.69754,407.4135;Inherit;False;Four Splats First Pass Terrain;0;;7;37452fdfb732e1443b7e39720d05b708;0;6;59;FLOAT4;0,0,0,0;False;60;FLOAT4;0,0,0,0;False;61;FLOAT3;0,0,0;False;57;FLOAT;0;False;58;FLOAT;0;False;62;FLOAT;0;False;6;FLOAT4;0;FLOAT3;14;FLOAT;56;FLOAT;45;FLOAT;19;FLOAT3;17
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;427.5953,110.7223;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Sando;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;-100;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;1;BaseMapShader=ASESampleShaders/SimpleTerrainBase;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;35;0;34;0
WireConnection;61;0;59;0
WireConnection;36;0;35;0
WireConnection;38;0;36;0
WireConnection;60;0;58;0
WireConnection;60;1;61;0
WireConnection;40;0;38;0
WireConnection;40;1;60;0
WireConnection;79;0;80;0
WireConnection;79;1;75;0
WireConnection;82;0;2;1
WireConnection;82;1;81;0
WireConnection;8;0;79;0
WireConnection;43;0;39;0
WireConnection;42;0;40;0
WireConnection;45;0;39;0
WireConnection;45;3;34;0
WireConnection;45;4;41;0
WireConnection;15;0;11;0
WireConnection;44;0;43;0
WireConnection;44;1;42;0
WireConnection;18;0;82;0
WireConnection;12;2;8;0
WireConnection;12;3;72;0
WireConnection;46;0;44;1
WireConnection;46;1;45;1
WireConnection;19;0;18;0
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;17;0;19;0
WireConnection;17;1;14;0
WireConnection;48;0;46;0
WireConnection;48;1;47;0
WireConnection;49;0;48;0
WireConnection;9;0;17;0
WireConnection;5;0;2;2
WireConnection;5;1;74;0
WireConnection;5;2;73;0
WireConnection;7;2;9;0
WireConnection;7;3;71;0
WireConnection;50;0;49;0
WireConnection;21;0;5;0
WireConnection;21;1;7;0
WireConnection;51;0;50;0
WireConnection;53;0;51;0
WireConnection;53;1;54;0
WireConnection;98;0;21;0
WireConnection;87;5;84;0
WireConnection;87;6;92;0
WireConnection;52;0;53;0
WireConnection;102;0;103;0
WireConnection;102;4;104;0
WireConnection;95;0;87;0
WireConnection;95;1;91;0
WireConnection;95;2;98;0
WireConnection;28;0;68;0
WireConnection;96;0;97;0
WireConnection;96;1;95;0
WireConnection;105;0;102;0
WireConnection;105;1;106;0
WireConnection;3;0;4;0
WireConnection;3;1;21;0
WireConnection;66;1;67;0
WireConnection;66;2;28;0
WireConnection;66;4;32;0
WireConnection;56;0;3;0
WireConnection;56;1;55;0
WireConnection;56;2;96;0
WireConnection;56;3;105;0
WireConnection;1;60;56;0
WireConnection;1;61;66;0
WireConnection;1;57;22;0
WireConnection;1;58;30;0
WireConnection;0;0;1;0
WireConnection;0;1;1;14
WireConnection;0;3;1;56
WireConnection;0;4;1;45
WireConnection;0;11;1;17
ASEEND*/
//CHKSM=027BB65CDDF48BF835169AADF2F693713FDC513F