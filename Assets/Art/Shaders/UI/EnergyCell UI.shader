// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EnergyCell UI"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		[HDR]_OutlineColor("Outline Color", Color) = (0,0,1.741101,0)
		_OutlineWidth("Outline Width", Float) = 0
		[HDR]_GlintColor("Glint Color", Color) = (0,0,0,0)
		_GlintScrollSpeed("Glint Scroll Speed", Float) = 0
		_GlowSpeed("Glow Speed", Float) = 0
		_Type("Type", Int) = 0
		_YellowFlickerSpeed("Yellow Flicker Speed", Float) = 0.5
		_RedFlickerSpeed("Red Flicker Speed", Float) = 0
		[HDR]_HDRColor("HDR Color", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			#include "UnityShaderVariables.cginc"

			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform int _Type;
			uniform float4 _GlintColor;
			uniform float _GlintScrollSpeed;
			uniform float4 _MainTex_ST;
			uniform float _RedFlickerSpeed;
			uniform float4 _HDRColor;
			uniform float _OutlineWidth;
			uniform float4 _OutlineColor;
			uniform float _YellowFlickerSpeed;
			uniform float _GlowSpeed;
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
			

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				int CellType110 = _Type;
				float cos10_g8 = cos( radians( 85.3 ) );
				float sin10_g8 = sin( radians( 85.3 ) );
				float2 rotator10_g8 = mul( IN.texcoord.xy - float2( 0.5,0.5 ) , float2x2( cos10_g8 , -sin10_g8 , sin10_g8 , cos10_g8 )) + float2( 0.5,0.5 );
				float2 appendResult8_g8 = (float2(0.1 , 1.0));
				float mulTime32 = _Time.y * _GlintScrollSpeed;
				float2 appendResult9_g8 = (float2(( 1.0 - mulTime32 ) , 0.0));
				float2 appendResult10_g9 = (float2(0.02 , 1.0));
				float2 temp_output_11_0_g9 = ( abs( (frac( (rotator10_g8*appendResult8_g8 + appendResult9_g8) )*2.0 + -1.0) ) - appendResult10_g9 );
				float2 break16_g9 = ( 1.0 - ( temp_output_11_0_g9 / fwidth( temp_output_11_0_g9 ) ) );
				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float4 blendOpSrc37 = ( ( (float)CellType110 <= 1.0 ? ( _GlintColor * saturate( min( break16_g9.x , break16_g9.y ) ) ) : float4( 0,0,0,0 ) ) + tex2DNode5 );
				float4 blendOpDest37 = tex2DNode5;
				float4 temp_output_37_0 = ( blendOpSrc37 * blendOpDest37 );
				float mulTime129 = _Time.y * _RedFlickerSpeed;
				float2 temp_cast_2 = (mulTime129).xx;
				float simplePerlin2D130 = snoise( temp_cast_2*2.0 );
				simplePerlin2D130 = simplePerlin2D130*0.5 + 0.5;
				float2 temp_cast_3 = (simplePerlin2D130).xx;
				float dotResult4_g6 = dot( temp_cast_3 , float2( 12.9898,78.233 ) );
				float lerpResult10_g6 = lerp( 0.5 , 1.2 , frac( ( sin( dotResult4_g6 ) * 43758.55 ) ));
				float RedCellFlicker120 = ( simplePerlin2D130 > 0.7 ? lerpResult10_g6 : 0.0 );
				float2 appendResult70 = (float2(_OutlineWidth , 0.0));
				float2 uv060 = IN.texcoord.xy * float2( 1,1 ) + appendResult70;
				float2 appendResult71 = (float2(0.0 , _OutlineWidth));
				float2 uv061 = IN.texcoord.xy * float2( 1,1 ) + appendResult71;
				float2 appendResult72 = (float2(( _OutlineWidth * -1.0 ) , 0.0));
				float2 uv062 = IN.texcoord.xy * float2( 1,1 ) + appendResult72;
				float2 appendResult73 = (float2(0.0 , ( _OutlineWidth * -1.0 )));
				float2 uv063 = IN.texcoord.xy * float2( 1,1 ) + appendResult73;
				float4 Outline108 = ( ( ( 1.0 - tex2DNode5.a ) * ( tex2D( _MainTex, uv060 ).a + tex2D( _MainTex, uv061 ).a + tex2D( _MainTex, uv062 ).a + tex2D( _MainTex, uv063 ).a ) ) * _OutlineColor );
				float mulTime97 = _Time.y * _YellowFlickerSpeed;
				float2 temp_cast_4 = (mulTime97).xx;
				float simplePerlin2D98 = snoise( temp_cast_4*2.0 );
				simplePerlin2D98 = simplePerlin2D98*0.5 + 0.5;
				float2 temp_cast_5 = (simplePerlin2D98).xx;
				float dotResult4_g10 = dot( temp_cast_5 , float2( 12.9898,78.233 ) );
				float lerpResult10_g10 = lerp( 0.5 , 0.8 , frac( ( sin( dotResult4_g10 ) * 43758.55 ) ));
				float YellowCellFlicker114 = ( simplePerlin2D98 > 0.2 ? 1.0 : lerpResult10_g10 );
				float mulTime90 = _Time.y * _GlowSpeed;
				float clampResult91 = clamp( sin( mulTime90 ) , 0.7 , 1.0 );
				float BlueCellBreathing117 = clampResult91;
				float ifLocalVar101 = 0;
				if( CellType110 > 1.0 )
				ifLocalVar101 = RedCellFlicker120;
				else if( CellType110 == 1.0 )
				ifLocalVar101 = YellowCellFlicker114;
				else if( CellType110 < 1.0 )
				ifLocalVar101 = BlueCellBreathing117;
				
				half4 color = ( ( temp_output_37_0 * ( (float)CellType110 == 2.0 ? ( ( RedCellFlicker120 + 0.4 ) * _HDRColor ) : _HDRColor ) ) + ( Outline108 * ifLocalVar101 ) + temp_output_37_0 );
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18100
-1920;0;1920;1029;2.74939;767.7748;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;82;-1056,0;Inherit;False;1731.714;856;Offset the sprite in each cardinal direction and multiply it with the inverted alpha of the sprite;20;76;78;80;79;65;75;74;72;73;71;70;62;63;61;60;56;57;58;59;77;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;128;-1056,1904;Inherit;False;1410;368;Red Flicker;6;120;127;131;130;129;133;Red Cell Outline Flicker;0.990566,0.1915717,0.3575196,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1008,48;Inherit;False;Property;_OutlineWidth;Outline Width;1;0;Create;True;0;0;False;0;False;0;0.025;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-1040,1968;Inherit;False;Property;_RedFlickerSpeed;Red Flicker Speed;7;0;Create;True;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;116;-1056,1296;Inherit;False;1423;480;Yellow Flickers;7;98;95;105;103;114;97;104;Yellow Cell Outline Flicker;1,0.8197487,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-752,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-752,624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;83;-1376,-848;Inherit;False;1075.714;480;Glimmer that scrolls over the sprite, creating a reflection like effect;6;25;32;39;38;22;26;Glint;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;129;-832,1968;Inherit;False;1;0;FLOAT;0.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-608,48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;72;-608,432;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1312,-624;Inherit;False;Property;_GlintScrollSpeed;Glint Scroll Speed;3;0;Create;True;0;0;False;0;False;0;0.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-608,624;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;71;-608,240;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;118;-1056,960;Inherit;False;905;209;Blue Breathing;5;93;90;89;91;117;Blue Cell Outline Glow;0,0.538238,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;130;-672,1968;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-1056,1344;Inherit;False;Property;_YellowFlickerSpeed;Yellow Flicker Speed;6;0;Create;True;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;60;-448,48;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;93;-1008,1008;Inherit;False;Property;_GlowSpeed;Glow Speed;4;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;62;-448,432;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-448,624;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-448,240;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;32;-1120,-624;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;6;-432,-240;Inherit;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;97;-848,1344;Inherit;False;1;0;FLOAT;0.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;131;-384.1092,2052.767;Inherit;True;Random Range;-1;;6;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.5;False;3;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;100;1472,-368;Inherit;False;Property;_Type;Type;5;0;Create;True;0;0;False;0;False;0;2;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;58;-176,432;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;56;-176,48;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;98;-672,1344;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;90;-864,1008;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-176,624;Inherit;True;Property;_TextureSample4;Texture Sample 4;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;39;-960,-624;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;127;-112,1968;Inherit;True;2;4;0;FLOAT;0;False;1;FLOAT;0.7;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;57;-176,240;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-176,-240;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-704,-800;Inherit;False;Property;_GlintColor;Glint Color;2;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;128,1968;Inherit;False;RedCellFlicker;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;192,112;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;77;192,48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;89;-688,1008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;38;-768,-624;Inherit;True;Stripes;-1;;8;8e73a71cdf24db740864b4c3f3357e7f;0;4;5;FLOAT;0.1;False;4;FLOAT;0;False;3;FLOAT;0.02;False;12;FLOAT;85.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;103;-368,1520;Inherit;True;Random Range;-1;;10;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.5;False;3;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-256,1408;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;1600,-368;Inherit;False;CellType;-1;True;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;384,-592;Inherit;False;120;RedCellFlicker;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-448,-624;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;95;-96,1344;Inherit;True;2;4;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;91;-560,1008;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.7;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;368,48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;80;240,272;Inherit;False;Property;_OutlineColor;Outline Color;0;1;[HDR];Create;True;0;0;False;0;False;0,0,1.741101,0;1.968628,0.6178599,0.4431988,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;113;-288,-672;Inherit;False;110;CellType;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;144,1344;Inherit;False;YellowCellFlicker;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;112;-112,-672;Inherit;False;5;4;0;INT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;632.7331,-572.0874;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-400,1008;Inherit;False;BlueCellBreathing;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;512,48;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;135;522.2001,-482.1002;Inherit;False;Property;_HDRColor;HDR Color;8;1;[HDR];Create;True;0;0;False;0;False;1,1,1,0;0.572549,0.5647059,0.5647059,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;119;896,208;Inherit;False;117;BlueCellBreathing;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;896,128;Inherit;False;114;YellowCellFlicker;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;144,-336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;759.7331,-547.0874;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;656,48;Inherit;False;Outline;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;139;560,-688;Inherit;False;110;CellType;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;896,48;Inherit;False;120;RedCellFlicker;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;896,-32;Inherit;False;110;CellType;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.ConditionalIfNode;101;1152,-32;Inherit;False;False;5;0;INT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;37;688,-256;Inherit;False;Multiply;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;136;954.7332,-572.0874;Inherit;False;0;4;0;INT;0;False;1;FLOAT;2;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;1120,-160;Inherit;False;108;Outline;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;1360,-160;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;1122.5,-402.5001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;141;720,-912;Inherit;False;Flipbook;-1;;11;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;3;False;5;FLOAT;3;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.SimpleAddOpNode;81;1520,-256;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;86;1648,-256;Float;False;True;-1;2;ASEMaterialInspector;0;5;EnergyCell UI;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;74;0;65;0
WireConnection;75;0;65;0
WireConnection;129;0;133;0
WireConnection;70;0;65;0
WireConnection;72;0;74;0
WireConnection;73;1;75;0
WireConnection;71;1;65;0
WireConnection;130;0;129;0
WireConnection;60;1;70;0
WireConnection;62;1;72;0
WireConnection;63;1;73;0
WireConnection;61;1;71;0
WireConnection;32;0;25;0
WireConnection;97;0;104;0
WireConnection;131;1;130;0
WireConnection;58;0;6;0
WireConnection;58;1;62;0
WireConnection;56;0;6;0
WireConnection;56;1;60;0
WireConnection;98;0;97;0
WireConnection;90;0;93;0
WireConnection;59;0;6;0
WireConnection;59;1;63;0
WireConnection;39;0;32;0
WireConnection;127;0;130;0
WireConnection;127;2;131;0
WireConnection;57;0;6;0
WireConnection;57;1;61;0
WireConnection;5;0;6;0
WireConnection;120;0;127;0
WireConnection;76;0;56;4
WireConnection;76;1;57;4
WireConnection;76;2;58;4
WireConnection;76;3;59;4
WireConnection;77;0;5;4
WireConnection;89;0;90;0
WireConnection;38;4;39;0
WireConnection;103;1;98;0
WireConnection;110;0;100;0
WireConnection;26;0;22;0
WireConnection;26;1;38;0
WireConnection;95;0;98;0
WireConnection;95;2;105;0
WireConnection;95;3;103;0
WireConnection;91;0;89;0
WireConnection;78;0;77;0
WireConnection;78;1;76;0
WireConnection;114;0;95;0
WireConnection;112;0;113;0
WireConnection;112;2;26;0
WireConnection;140;0;137;0
WireConnection;117;0;91;0
WireConnection;79;0;78;0
WireConnection;79;1;80;0
WireConnection;20;0;112;0
WireConnection;20;1;5;0
WireConnection;138;0;140;0
WireConnection;138;1;135;0
WireConnection;108;0;79;0
WireConnection;101;0;111;0
WireConnection;101;2;121;0
WireConnection;101;3;115;0
WireConnection;101;4;119;0
WireConnection;37;0;20;0
WireConnection;37;1;5;0
WireConnection;136;0;139;0
WireConnection;136;2;138;0
WireConnection;136;3;135;0
WireConnection;87;0;109;0
WireConnection;87;1;101;0
WireConnection;134;0;37;0
WireConnection;134;1;136;0
WireConnection;81;0;134;0
WireConnection;81;1;87;0
WireConnection;81;2;37;0
WireConnection;86;0;81;0
ASEEND*/
//CHKSM=F7458C7D1930AC67AD41C2F7910E90AF69428267