// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EnemyDeathDissolve"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_DissolveAmount("DissolveAmount", Range( 0 , 1)) = 0
		_Albedo("Albedo", Color) = (0,0,0,0)
		[HDR]_BorderColor("BorderColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Albedo;
		uniform float _DissolveAmount;
		uniform float4 _BorderColor;
		uniform float _Cutoff = 0.5;


		float2 voronoihash13( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13( float2 v, float time, inout float2 id, float smoothness )
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
			 		float2 o = voronoihash13( n + g );
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
			return (F2 + F1) * 0.5;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _Albedo.rgb;
			float time13 = 3.66;
			float2 coords13 = i.uv_texcoord * 7.3;
			float2 id13 = 0;
			float fade13 = 0.5;
			float voroi13 = 0;
			float rest13 = 0;
			for( int it13 = 0; it13 <2; it13++ ){
			voroi13 += fade13 * voronoi13( coords13, time13, id13,0 );
			rest13 += fade13;
			coords13 *= 2;
			fade13 *= 0.5;
			}//Voronoi13
			voroi13 /= rest13;
			float temp_output_14_0 = ( _DissolveAmount * 0.6 );
			float temp_output_3_0 = step( voroi13 , temp_output_14_0 );
			o.Emission = ( ( temp_output_3_0 * ( 1.0 - step( voroi13 , ( temp_output_14_0 - 0.1 ) ) ) ) * _BorderColor ).rgb;
			o.Alpha = 1;
			clip( temp_output_3_0 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
-1920;6;1920;1023;1575.174;315.5365;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;4;-1100.887,-218.6152;Inherit;False;Property;_DissolveAmount;DissolveAmount;1;0;Create;True;0;0;False;0;False;0;0.1260412;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-1201.677,-69.65833;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-773.1736,-172.5365;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-800.6493,334.0403;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;13;-1131.174,173.4635;Inherit;True;0;0;1;3;2;False;2;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;3.66;False;2;FLOAT;7.3;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT2;1
Node;AmplifyShaderEditor.StepOpNode;5;-592.5043,258.9664;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;3;-597.8871,-69.61523;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.13;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;8;-374.2131,290.4258;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-192.2063,243.0431;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-189.2131,464.4258;Inherit;False;Property;_BorderColor;BorderColor;3;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;3.987934,1.222716,1.595532,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;2;-966.019,-72.88393;Inherit;True;Simplex2D;True;True;2;0;FLOAT2;0,0;False;1;FLOAT;-10.95;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;108.7869,215.4258;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;9;83.78687,-235.5742;Inherit;False;Property;_Albedo;Albedo;2;0;Create;True;0;0;False;0;False;0,0,0,0;0.3490195,0.3490195,0.3490195,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;500,-200;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;EnemyDeathDissolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;4;0
WireConnection;6;0;14;0
WireConnection;13;0;1;0
WireConnection;5;0;13;0
WireConnection;5;1;6;0
WireConnection;3;0;13;0
WireConnection;3;1;14;0
WireConnection;8;0;5;0
WireConnection;7;0;3;0
WireConnection;7;1;8;0
WireConnection;2;0;1;0
WireConnection;11;0;7;0
WireConnection;11;1;12;0
WireConnection;0;0;9;0
WireConnection;0;2;11;0
WireConnection;0;10;3;0
ASEEND*/
//CHKSM=D8952663577D03144DFA4C4AD844B02BA6724316