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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color12 = IsGammaSpace() ? float4(0.4002819,0.3349057,1,0) : float4(0.133066,0.09172697,1,0);
			Gradient gradient8 = NewGradient( 1, 2, 4, float4( 0, 0, 0, 0.5112688 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 0.4819867 ), float2( 1, 0.7725185 ), float2( 1, 1 ), 0, 0, 0, 0 );
			float time1 = 0.0;
			float2 temp_cast_0 = (3.63).xx;
			float2 uv_TexCoord5 = i.uv_texcoord * ( temp_cast_0 % float2( 1.5,0.75 ) );
			float2 coords1 = uv_TexCoord5 * 5.92;
			float2 id1 = 0;
			float voroi1 = voronoi1( coords1, time1,id1, 0 );
			float time6 = 0.0;
			float2 coords6 = uv_TexCoord5 * 5.92;
			float2 id6 = 0;
			float voroi6 = voronoi6( coords6, time6,id6, 0 );
			float temp_output_7_0 = ( voroi1 - voroi6 );
			float temp_output_1_0_g15 = ( temp_output_7_0 * float4( 10.63,1.43,0,-7.62 ) ).x;
			float mulTime25 = _Time.y * 0.2;
			float2 temp_cast_2 = (mulTime25).xx;
			float2 uv_TexCoord36 = i.uv_texcoord + temp_cast_2;
			float2 panner30 = ( 1.0 * _Time.y * float2( 0,0.2 ) + uv_TexCoord36);
			float simplePerlin2D53 = snoise( ( id1 + panner30 )*float3(0.62,3.8,0).x );
			simplePerlin2D53 = simplePerlin2D53*0.5 + 0.5;
			float smoothstepResult57 = smoothstep( 0.62 , 0.8 , simplePerlin2D53);
			o.Emission = ( color12 * ( SampleGradient( gradient8, ( ( abs( ( ( temp_output_1_0_g15 - floor( ( temp_output_1_0_g15 + 0.5 ) ) ) * 2 ) ) * 2 ) - 1.0 ) ) * smoothstepResult57 ) * 4.04 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
2730;134;2420;1138;863.5427;330.0325;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;50;-2256.107,176.9557;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;False;0;False;3.63;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;48;-2255.107,348.9557;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;False;1.5,0.75;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleRemainderNode;49;-2010.107,235.9557;Inherit;False;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;25;-1455.86,889.9374;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1753.3,182.2247;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;6;-1045.284,155.2983;Inherit;True;0;3;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;5.92;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT2;1
Node;AmplifyShaderEditor.VoronoiNode;1;-1030.118,-136.2415;Inherit;True;0;3;1;1;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;5.92;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT2;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-963.4524,797.7947;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;7;-551.2839,-38.70166;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;30;-611.2809,904.6113;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-241.1204,625.0804;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-120.0251,8.612488;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;10.63,1.43,0,-7.62;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;55;-124.8247,1127.171;Inherit;False;Constant;_Vector1;Vector 1;1;0;Create;True;0;0;False;0;False;0.62,3.8,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;53;114.6971,915.4955;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;8;41.71606,214.8983;Inherit;False;1;2;4;0,0,0,0.5112688;1,1,1,1;1,0;1,0.4819867;1,0.7725185;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.FunctionNode;32;63.5575,-49.24097;Inherit;True;Triangle Wave;-1;;15;51ec3c8d117f3ec4fa3742c3e00d535b;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;9;339.8832,130.107;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;57;442.1127,761.4468;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.62;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;701.413,472.8892;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;20;402.8137,-4.335693;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;4.04;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;359.6361,-230.9819;Inherit;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;False;0;False;0.4002819,0.3349057,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;18;-334.1562,-1074.156;Inherit;True;Truchet;-1;;13;600b4e63537aa56498ba8983340930ed;0;5;25;FLOAT2;8,8;False;6;FLOAT;19.7;False;33;FLOAT;0.66;False;34;FLOAT;0.05;False;19;FLOAT;165.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;10;-347.2935,-1311.204;Inherit;True;Hex Lattice;-1;;5;56d977fb137832a498dced8436cf6708;0;3;3;FLOAT2;10,10;False;2;FLOAT;1;False;4;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1028.55,-1157.417;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;False;0;False;1.81;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-270.7811,234.7385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3.88;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;4;-1716.548,-388.5593;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;0;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;34;-2230.536,-642.1989;Inherit;True;0;3;1;1;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;5.92;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleRemainderNode;21;-770.9181,-1316.92;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;51;-542.1771,1233.476;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-614.0479,754.4662;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;False;0;False;3.77;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;45;-135.2985,244.485;Inherit;True;Triangle Wave;-1;;15;51ec3c8d117f3ec4fa3742c3e00d535b;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;37;-1256.048,406.4662;Inherit;True;0;3;1;0;1;False;-2;False;True;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;5.92;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;1272.214,41.16431;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1648.735,132.7155;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;49;0;50;0
WireConnection;49;1;48;0
WireConnection;5;0;49;0
WireConnection;6;0;5;0
WireConnection;1;0;5;0
WireConnection;36;1;25;0
WireConnection;7;0;1;0
WireConnection;7;1;6;0
WireConnection;30;0;36;0
WireConnection;44;0;1;1
WireConnection;44;1;30;0
WireConnection;33;0;7;0
WireConnection;53;0;44;0
WireConnection;53;1;55;0
WireConnection;32;1;33;0
WireConnection;9;0;8;0
WireConnection;9;1;32;0
WireConnection;57;0;53;0
WireConnection;43;0;9;0
WireConnection;43;1;57;0
WireConnection;46;0;7;0
WireConnection;21;0;23;0
WireConnection;45;1;46;0
WireConnection;37;0;5;0
WireConnection;19;0;12;0
WireConnection;19;1;43;0
WireConnection;19;2;20;0
WireConnection;0;2;19;0
ASEEND*/
//CHKSM=7FC32B0405BAE6F7DAF09ED140682AB81147824E