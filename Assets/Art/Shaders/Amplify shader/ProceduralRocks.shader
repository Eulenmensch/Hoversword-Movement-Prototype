// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ProceduralRocks"
{
	Properties
	{
		_Scale("Scale", Float) = 0
		_voronoi_offset("voronoi_offset", Float) = 0.12
		_Offset("Offset", Float) = 0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample2("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 0", 2D) = "white" {}
		_Ynormaltextureblend("Y normal texture blend", Float) = 0
		_YNormColor("Y Norm Color ", Color) = (0.4509804,0.3254902,0.2313726,1)
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
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
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

		uniform sampler2D _TextureSample2;
		uniform sampler2D _TextureSample0;
		uniform float _Scale;
		uniform float _Offset;
		uniform float _voronoi_offset;
		uniform sampler2D _TextureSample1;
		uniform float4 _YNormColor;
		uniform float _Ynormaltextureblend;


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


		float2 voronoihash43( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi43( float2 v, float time, inout float2 id, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mr = 0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash43( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
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


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
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
			Gradient gradient4 = NewGradient( 0, 4, 2, float4( 1, 0.6686293, 0.3254902, 0 ), float4( 1, 0.6311321, 0.2783019, 0.05404745 ), float4( 0.9056604, 0.3889429, 0.3203987, 0.5788357 ), float4( 0.3676575, 0.3862092, 0.509434, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float2 temp_cast_0 = (2.0).xx;
			float2 uv_TexCoord55 = i.uv_texcoord * temp_cast_0;
			float4 tex2DNode52 = tex2D( _TextureSample2, uv_TexCoord55 );
			float div57=256.0/float(3);
			float4 posterize57 = ( floor( tex2DNode52 * div57 ) / div57 );
			float time43 = 34.25;
			float3 ase_worldPos = i.worldPos;
			float2 temp_cast_1 = (ase_worldPos.y).xx;
			float2 coords43 = temp_cast_1 * 0.33;
			float2 id43 = 0;
			float voroi43 = voronoi43( coords43, time43,id43, 0 );
			float2 lerpResult36 = lerp( i.uv_texcoord , id43 , 2.57);
			float4 temp_cast_2 = ((ase_worldPos.y*_Scale + _Offset)).xxxx;
			float4 lerpResult22 = lerp( tex2D( _TextureSample0, lerpResult36 ) , temp_cast_2 , _voronoi_offset);
			float4 blendOpSrc54 = posterize57;
			float4 blendOpDest54 = lerpResult22;
			float4 lerpBlendMode54 = lerp(blendOpDest54,( blendOpDest54 - blendOpSrc54 ),0.1);
			Gradient gradient42 = NewGradient( 1, 2, 2, float4( 0.9811321, 0.6054241, 0.3285867, 0.004501412 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float4 temp_cast_4 = (voroi43).xxxx;
			float4 blendOpSrc51 = temp_cast_4;
			float4 blendOpDest51 = tex2D( _TextureSample1, lerpResult36 );
			Gradient gradient35 = NewGradient( 1, 2, 2, float4( 0, 0, 0, 0.5157702 ), float4( 1, 1, 1, 0.7252308 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float4 temp_cast_6 = (ase_vertexNormal.y).xxxx;
			float4 blendOpSrc53 = tex2DNode52;
			float4 blendOpDest53 = temp_cast_6;
			float4 lerpBlendMode53 = lerp(blendOpDest53,( blendOpSrc53 * blendOpDest53 ),_Ynormaltextureblend);
			float simplePerlin3D63 = snoise( ase_worldPos*0.02 );
			simplePerlin3D63 = simplePerlin3D63*0.5 + 0.5;
			float4 temp_cast_7 = (simplePerlin3D63).xxxx;
			float4 lerpResult65 = lerp( lerpBlendMode53 , temp_cast_7 , float4( 0.6132076,0.6132076,0.6132076,0 ));
			float4 lerpResult62 = lerp( ( SampleGradient( gradient4, lerpBlendMode54.r ) * SampleGradient( gradient42, ( blendOpSrc51 * blendOpDest51 ).r ) ) , _YNormColor , SampleGradient( gradient35, lerpResult65.r ));
			Gradient gradient28 = NewGradient( 1, 2, 2, float4( 0.8490566, 0.4795764, 0.2042542, 0.7252308 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			c.rgb = ( lerpResult62 * SampleGradient( gradient28, (ase_lightAtten*0.5 + 0.55) ) ).rgb;
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
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
1371;44;1189;985;944.3585;399.8637;1.265789;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-2801.016,-123.005;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-1969.087,-645.6396;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;-1277.417,-856.413;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1849.213,-155.2716;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;2.57;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;43;-2327.159,-268.2252;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;34.25;False;2;FLOAT;0.33;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;10;-1873.492,-57.36856;Inherit;False;Property;_Scale;Scale;0;0;Create;True;0;0;False;0;False;0;0.005;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;36;-1587.625,-330.1851;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;55;-1084.59,-934.1754;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-1870.925,36.31664;Inherit;False;Property;_Offset;Offset;2;0;Create;True;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;5;-1014.054,-167.3828;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.005;False;2;FLOAT;-1.21;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;52;-658.1434,-626.678;Inherit;True;Property;_TextureSample2;Texture Sample 0;4;0;Create;True;0;0;False;0;False;-1;None;bbfd0f3cee807c04bbbd9b488beb9409;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-1108.814,-559.7475;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;False;-1;None;90c4df6925ca99245b250280e0ed35a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-1007.244,17.54258;Inherit;False;Property;_voronoi_offset;voronoi_offset;1;0;Create;True;0;0;False;0;False;0.12;1.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;57;-343.5052,-406.2789;Inherit;False;3;2;1;COLOR;0,0,0,0;False;0;INT;3;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;49;-1401.929,140.0875;Inherit;True;Property;_TextureSample1;Texture Sample 0;5;0;Create;True;0;0;False;0;False;-1;None;a3a5212df9b830b4cacd363707d90135;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;22;-371.6503,-219.7894;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-552.8938,204.0011;Inherit;False;Property;_Ynormaltextureblend;Y normal texture blend;6;0;Create;True;0;0;False;0;False;0;0.66;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;32;-631.5609,68.99868;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientNode;4;-273.8643,-504.8643;Inherit;False;0;4;2;1,0.6686293,0.3254902,0;1,0.6311321,0.2783019,0.05404745;0.9056604,0.3889429,0.3203987,0.5788357;0.3676575,0.3862092,0.509434,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.BlendOpsNode;53;-306.3365,124.689;Inherit;False;Multiply;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.75;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;63;-428.6497,499.2879;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;42;-866.1761,295.6715;Inherit;False;1;2;2;0.9811321,0.6054241,0.3285867,0.004501412;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.BlendOpsNode;51;-965.104,463.0416;Inherit;False;Multiply;False;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;54;-92.8868,-188.9204;Inherit;False;Subtract;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.1;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;41;-657.4943,292.5184;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;26;-492.138,1669.634;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;65;6.375344,387.4571;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.6132076,0.6132076,0.6132076,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;35;-312.7041,-5.866661;Inherit;False;1;2;2;0,0,0,0.5157702;1,1,1,0.7252308;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GradientSampleNode;3;68.11723,-308.3056;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;174.7114,-514.6635;Inherit;False;Property;_YNormColor;Y Norm Color ;7;0;Create;True;0;0;False;0;False;0.4509804,0.3254902,0.2313726,1;0.9150943,0.6318322,0.4791295,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;30;-252.4958,1656.461;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.55;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;28;-259.1479,1335.224;Inherit;False;1;2;2;0.8490566,0.4795764,0.2042542,0.7252308;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;362.8809,-53.93793;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;34;229.163,262.7047;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientSampleNode;29;57.43752,1500.19;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;62;583.2531,128.336;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;64;185.8884,586.1857;Inherit;False;Lighten;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;803.8177,197.0789;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1188.098,87.79941;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ProceduralRocks;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;43;0;2;2
WireConnection;36;0;16;0
WireConnection;36;1;43;1
WireConnection;36;2;25;0
WireConnection;55;0;56;0
WireConnection;5;0;2;2
WireConnection;5;1;10;0
WireConnection;5;2;11;0
WireConnection;52;1;55;0
WireConnection;21;1;36;0
WireConnection;57;1;52;0
WireConnection;49;1;36;0
WireConnection;22;0;21;0
WireConnection;22;1;5;0
WireConnection;22;2;9;0
WireConnection;53;0;52;0
WireConnection;53;1;32;2
WireConnection;53;2;58;0
WireConnection;63;0;2;0
WireConnection;51;0;43;0
WireConnection;51;1;49;0
WireConnection;54;0;57;0
WireConnection;54;1;22;0
WireConnection;41;0;42;0
WireConnection;41;1;51;0
WireConnection;65;0;53;0
WireConnection;65;1;63;0
WireConnection;3;0;4;0
WireConnection;3;1;54;0
WireConnection;30;0;26;0
WireConnection;39;0;3;0
WireConnection;39;1;41;0
WireConnection;34;0;35;0
WireConnection;34;1;65;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;62;0;39;0
WireConnection;62;1;61;0
WireConnection;62;2;34;0
WireConnection;27;0;62;0
WireConnection;27;1;29;0
WireConnection;0;13;27;0
ASEEND*/
//CHKSM=3ECF0B2A28D77179AB239F44A759F2D6AD8DFA40