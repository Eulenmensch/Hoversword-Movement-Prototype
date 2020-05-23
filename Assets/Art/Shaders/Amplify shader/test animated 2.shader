// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "test"
{
	Properties
	{
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};


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


		float2 voronoihash1( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi1( float2 v, float time, inout float2 id, float smoothness )
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
			 		float2 o = voronoihash1( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = max(abs(r.x), abs(r.y));
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F2;
		}


		float2 voronoihash6( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi6( float2 v, float time, inout float2 id, float smoothness )
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
			 		float2 o = voronoihash6( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = max(abs(r.x), abs(r.y));
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


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color68 = IsGammaSpace() ? float4(0.3207547,0.3207547,0.3207547,0) : float4(0.08393918,0.08393918,0.08393918,0);
			o.Albedo = color68.rgb;
			float4 color12 = IsGammaSpace() ? float4(0.3333334,1,0.4476905,0) : float4(0.09084175,1,0.168778,0);
			Gradient gradient8 = NewGradient( 1, 2, 4, float4( 0, 0, 0, 0.3626154 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 0.4819867 ), float2( 1, 0.7725185 ), float2( 1, 1 ), 0, 0, 0, 0 );
			float time1 = 0.0;
			float2 uv_TexCoord5 = i.uv_texcoord * float2( 0.7,4.58 );
			float2 coords1 = uv_TexCoord5 * 5.95;
			float2 id1 = 0;
			float voroi1 = voronoi1( coords1, time1,id1, 0 );
			float time6 = 0.0;
			float2 coords6 = uv_TexCoord5 * 5.95;
			float2 id6 = 0;
			float voroi6 = voronoi6( coords6, time6,id6, 0 );
			float temp_output_7_0 = ( voroi1 - voroi6 );
			float temp_output_1_0_g15 = ( temp_output_7_0 * 10.63 );
			float2 temp_cast_1 = (temp_output_7_0).xx;
			float simplePerlin2D58 = snoise( temp_cast_1*5.18 );
			simplePerlin2D58 = simplePerlin2D58*0.5 + 0.5;
			float smoothstepResult60 = smoothstep( simplePerlin2D58 , 0.82 , 0.0);
			float mulTime25 = _Time.y * 0.31;
			float2 temp_cast_2 = (mulTime25).xx;
			float2 uv_TexCoord36 = i.uv_texcoord + temp_cast_2;
			float2 temp_cast_3 = (( uv_TexCoord36.y % 0.54 )).xx;
			float simplePerlin2D53 = snoise( temp_cast_3*2.89 );
			simplePerlin2D53 = simplePerlin2D53*0.5 + 0.5;
			float smoothstepResult57 = smoothstep( 0.14 , 1.38 , simplePerlin2D53);
			o.Emission = ( color12 * ( SampleGradient( gradient8, ( ( ( abs( ( ( temp_output_1_0_g15 - floor( ( temp_output_1_0_g15 + 0.5 ) ) ) * 2 ) ) * 2 ) - 1.0 ) * smoothstepResult60 ) ) * smoothstepResult57 ) * 4.04 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
596;186;2068;1372;6984.321;1895.576;4.70841;True;True
Node;AmplifyShaderEditor.Vector2Node;48;-2777.899,199.8685;Inherit;True;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;False;0.7,4.58;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1753.3,182.2247;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;70;-1501.534,-162.828;Inherit;False;Constant;_Float2;Float 2;0;0;Create;True;0;0;False;0;False;5.95;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;1;-1030.118,-136.2415;Inherit;True;0;3;1;1;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;5.92;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleTimeNode;25;-1407.703,900.8195;Inherit;False;1;0;FLOAT;0.31;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;6;-1045.284,155.2983;Inherit;True;0;3;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;5.92;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleSubtractOpNode;7;-551.2839,-38.70166;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-1014.455,914.7614;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-121.0251,8.612488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10.63;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;65;-648.595,849.1429;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NoiseGeneratorNode;58;-169.2277,359.5679;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;5.18;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;60;82.77234,375.5679;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.62;False;2;FLOAT;0.82;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;32;63.5575,-49.24097;Inherit;True;Triangle Wave;-1;;15;51ec3c8d117f3ec4fa3742c3e00d535b;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;69;-399.0684,978.165;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.54;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;53;-26.88715,882.2804;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2.89;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;344.7723,407.5679;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;10.63;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;8;41.71606,214.8983;Inherit;False;1;2;4;0,0,0,0.3626154;1,1,1,1;1,0;1,0.4819867;1,0.7725185;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GradientSampleNode;9;473.8832,180.107;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;57;360.1127,716.4468;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.14;False;2;FLOAT;1.38;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;701.413,472.8892;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;12;359.6361,-230.9819;Inherit;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;False;0;False;0.3333334,1,0.4476905,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;402.8137,-4.335693;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;4.04;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;68;1098.374,-160.1203;Inherit;False;Constant;_Color1;Color 1;1;0;Create;True;0;0;False;0;False;0.3207547,0.3207547,0.3207547,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;1230.214,271.1643;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1648.735,132.7155;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;48;0
WireConnection;1;0;5;0
WireConnection;1;2;70;0
WireConnection;6;0;5;0
WireConnection;6;2;70;0
WireConnection;7;0;1;0
WireConnection;7;1;6;0
WireConnection;36;1;25;0
WireConnection;33;0;7;0
WireConnection;65;0;36;0
WireConnection;58;0;7;0
WireConnection;60;1;58;0
WireConnection;32;1;33;0
WireConnection;69;0;65;1
WireConnection;53;0;69;0
WireConnection;59;0;32;0
WireConnection;59;1;60;0
WireConnection;9;0;8;0
WireConnection;9;1;59;0
WireConnection;57;0;53;0
WireConnection;43;0;9;0
WireConnection;43;1;57;0
WireConnection;19;0;12;0
WireConnection;19;1;43;0
WireConnection;19;2;20;0
WireConnection;0;0;68;0
WireConnection;0;2;19;0
ASEEND*/
//CHKSM=1302850A59868AD31C7709EA1B9B97306CCEA611