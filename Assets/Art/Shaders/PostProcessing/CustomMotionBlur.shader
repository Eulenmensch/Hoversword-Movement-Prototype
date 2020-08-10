// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CustomMotionBlur"
{
	Properties
	{
		_NoiseScale("NoiseScale", Range( 1 , 20)) = 17.28066
		_MaskRadius("MaskRadius", Range( 0 , 20)) = 0
		_Offset("Offset", Vector) = (0.5,0.5,0,0)

	}

	SubShader
	{
		LOD 0

		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_VERT_SCREEN_POSITION_NORMALIZED

		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float2 _Offset;
			uniform float _NoiseScale;
			uniform float _MaskRadius;


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
			

			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoordStereo;
				float4 ase_ppsScreenPosVertexNorm = float4(o.texcoordStereo,0,1);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord3.xyz = ase_worldPos;
				float4 vertexToFrag106 = ase_ppsScreenPosVertexNorm;
				o.ase_texcoord4 = vertexToFrag106;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,0,1);

				float2 uv0145 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 ase_worldPos = i.ase_texcoord3.xyz;
				float3 temp_output_16_0_g18 = ( ase_worldPos * 100.0 );
				float3 crossY18_g18 = cross( ase_worldNormal , ddy( temp_output_16_0_g18 ) );
				float3 worldDerivativeX2_g18 = ddx( temp_output_16_0_g18 );
				float dotResult6_g18 = dot( crossY18_g18 , worldDerivativeX2_g18 );
				float crossYDotWorldDerivX34_g18 = abs( dotResult6_g18 );
				float2 uv0148 = i.texcoord.xy * float2( 1,1 ) + ( _Offset * -1.0 );
				float2 CenteredUV15_g13 = ( uv0148 - float2( 0,0 ) );
				float2 break17_g13 = CenteredUV15_g13;
				float2 appendResult23_g13 = (float2(( length( CenteredUV15_g13 ) * 0.03 * 2.0 ) , ( atan2( break17_g13.x , break17_g13.y ) * ( 1.0 / 6.28318548202515 ) * 1.81 )));
				float mulTime199 = _Time.y * 10.61;
				float cos216 = cos( mulTime199 );
				float sin216 = sin( mulTime199 );
				float2 rotator216 = mul( appendResult23_g13 - float2( 0,0 ) , float2x2( cos216 , -sin216 , sin216 , cos216 )) + float2( 0,0 );
				float simplePerlin3D147 = snoise( float3( rotator216 ,  0.0 )*_NoiseScale );
				simplePerlin3D147 = simplePerlin3D147*0.5 + 0.5;
				float4 vertexToFrag106 = i.ase_texcoord4;
				float smoothstepResult198 = smoothstep( 0.0 , _MaskRadius , length( ( (vertexToFrag106).xy - _Offset ) ));
				float blendOpSrc195 = 0.0;
				float blendOpDest195 = ( simplePerlin3D147 * smoothstepResult198 );
				float lerpBlendMode195 = lerp(blendOpDest195,( blendOpSrc195 * blendOpDest195 ),0.2);
				float temp_output_20_0_g18 = ( saturate( lerpBlendMode195 ));
				float3 crossX19_g18 = cross( ase_worldNormal , worldDerivativeX2_g18 );
				float3 break29_g18 = ( sign( crossYDotWorldDerivX34_g18 ) * ( ( ddx( temp_output_20_0_g18 ) * crossY18_g18 ) + ( ddy( temp_output_20_0_g18 ) * crossX19_g18 ) ) );
				float3 appendResult30_g18 = (float3(break29_g18.x , -break29_g18.y , break29_g18.z));
				float3 normalizeResult39_g18 = normalize( ( ( crossYDotWorldDerivX34_g18 * ase_worldNormal ) - appendResult30_g18 ) );
				float3 temp_output_186_0 = normalizeResult39_g18;
				

				float4 color = tex2D( _MainTex, ( float3( uv0145 ,  0.0 ) + temp_output_186_0 ).xy );
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18100
-1920;12;1920;1017;3948.465;694.9531;1.3;True;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;97;-3351.118,-66.67619;Float;True;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;227;-3343.965,-288.053;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;220;-3374.246,-409.9841;Inherit;False;Property;_Offset;Offset;2;0;Create;True;0;0;False;0;False;0.5,0.5;-0.5,-0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;-3104.765,-405.0531;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;106;-3027.431,-67.18472;Inherit;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;98;-2816.452,-72.16915;Inherit;True;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;148;-2910.042,-431.3465;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;-0.5,-0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-2576.041,-72.73441;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;196;-2697.567,-431.5942;Inherit;False;Polar Coordinates;-1;;13;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0.03;False;4;FLOAT;1.81;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;199;-2650.515,-277.4388;Inherit;False;1;0;FLOAT;10.61;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-2561.503,-205.3281;Inherit;False;Property;_NoiseScale;NoiseScale;0;0;Create;True;0;0;False;0;False;17.28066;20;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;101;-2438.114,-73.54544;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-2016,138.3963;Inherit;False;Property;_MaskRadius;MaskRadius;1;0;Create;True;0;0;False;0;False;0;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;216;-2465.15,-430.7483;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;147;-2277.355,-435.0621;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;198;-2241.726,-158.5969;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;-2027.927,-277.3378;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;195;-1886.397,-356.2276;Inherit;True;Multiply;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;186;-1602.743,-301.4629;Inherit;True;Normal From Height;-1;;18;1942fe2c5f1a1f94881a33d532e4afeb;0;1;20;FLOAT;0;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;145;-1237.091,-248.4064;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;146;-1002.422,-136.3104;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;142;-1015.883,-419.2734;Inherit;True;0;0;_MainTex;Pass;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-1227.1,-124.2037;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;10;-753.599,-137.5219;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;153;-1593.899,-28.3038;Inherit;True;SphereMask;-1;;17;988803ee12caf5f4690caee3c8c4a5bb;0;3;15;FLOAT2;0,0;False;14;FLOAT;5.3;False;12;FLOAT;1.55;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;222;-459.1938,-132.5017;Float;False;True;-1;2;ASEMaterialInspector;0;2;CustomMotionBlur;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;226;0;220;0
WireConnection;226;1;227;0
WireConnection;106;0;97;0
WireConnection;98;0;106;0
WireConnection;148;1;226;0
WireConnection;100;0;98;0
WireConnection;100;1;220;0
WireConnection;196;1;148;0
WireConnection;101;0;100;0
WireConnection;216;0;196;0
WireConnection;216;2;199;0
WireConnection;147;0;216;0
WireConnection;147;1;149;0
WireConnection;198;0;101;0
WireConnection;198;2;155;0
WireConnection;197;0;147;0
WireConnection;197;1;198;0
WireConnection;195;1;197;0
WireConnection;186;20;195;0
WireConnection;146;0;145;0
WireConnection;146;1;186;0
WireConnection;154;0;186;0
WireConnection;154;1;153;0
WireConnection;10;0;142;0
WireConnection;10;1;146;0
WireConnection;153;14;155;0
WireConnection;222;0;10;0
ASEEND*/
//CHKSM=31F520BBD6E91BBCEB26EA3C726A72733A017B70