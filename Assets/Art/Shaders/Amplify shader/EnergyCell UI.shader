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
			uniform float4 _GlintColor;
			uniform float _GlintScrollSpeed;
			uniform float4 _MainTex_ST;
			uniform float _OutlineWidth;
			uniform float4 _OutlineColor;

			
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
				float cos10_g1 = cos( radians( 85.3 ) );
				float sin10_g1 = sin( radians( 85.3 ) );
				float2 rotator10_g1 = mul( IN.texcoord.xy - float2( 0.5,0.5 ) , float2x2( cos10_g1 , -sin10_g1 , sin10_g1 , cos10_g1 )) + float2( 0.5,0.5 );
				float2 appendResult8_g1 = (float2(0.1 , 1.0));
				float mulTime32 = _Time.y * _GlintScrollSpeed;
				float2 appendResult9_g1 = (float2(( 1.0 - mulTime32 ) , 0.0));
				float2 appendResult10_g2 = (float2(0.02 , 1.0));
				float2 temp_output_11_0_g2 = ( abs( (frac( (rotator10_g1*appendResult8_g1 + appendResult9_g1) )*2.0 + -1.0) ) - appendResult10_g2 );
				float2 break16_g2 = ( 1.0 - ( temp_output_11_0_g2 / fwidth( temp_output_11_0_g2 ) ) );
				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float4 blendOpSrc37 = ( ( _GlintColor * saturate( min( break16_g2.x , break16_g2.y ) ) ) + tex2DNode5 );
				float4 blendOpDest37 = tex2DNode5;
				float2 appendResult70 = (float2(_OutlineWidth , 0.0));
				float2 uv060 = IN.texcoord.xy * float2( 1,1 ) + appendResult70;
				float2 appendResult71 = (float2(0.0 , _OutlineWidth));
				float2 uv061 = IN.texcoord.xy * float2( 1,1 ) + appendResult71;
				float2 appendResult72 = (float2(( _OutlineWidth * -1.0 ) , 0.0));
				float2 uv062 = IN.texcoord.xy * float2( 1,1 ) + appendResult72;
				float2 appendResult73 = (float2(0.0 , ( _OutlineWidth * -1.0 )));
				float2 uv063 = IN.texcoord.xy * float2( 1,1 ) + appendResult73;
				
				half4 color = ( ( blendOpSrc37 * blendOpDest37 ) + ( ( ( 1.0 - tex2DNode5.a ) * ( tex2D( _MainTex, uv060 ).a + tex2D( _MainTex, uv061 ).a + tex2D( _MainTex, uv062 ).a + tex2D( _MainTex, uv063 ).a ) ) * _OutlineColor ) );
				
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
0;0;2194;1182;899.895;770.3834;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;82;-1056,0;Inherit;False;1731.714;856;Offset the sprite in each cardinal direction and multiply it with the inverted alpha of the sprite;20;76;78;80;79;65;75;74;72;73;71;70;62;63;61;60;56;57;58;59;77;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1008,48;Inherit;False;Property;_OutlineWidth;Outline Width;1;0;Create;True;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;83;-962,-738;Inherit;False;1075.714;480;Glimmer that scrolls over the sprite, creating a reflection like effect;6;25;32;39;38;22;26;Glint;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-752,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-752,624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-912,-512;Inherit;False;Property;_GlintScrollSpeed;Glint Scroll Speed;3;0;Create;True;0;0;False;0;False;0;0.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-608,48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;32;-720,-512;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-608,624;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;71;-608,240;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;72;-608,432;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;60;-448,48;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-448,624;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;39;-560,-512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;6;-432,-240;Inherit;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;62;-448,432;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-448,240;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;56;-176,48;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-304,-688;Inherit;False;Property;_GlintColor;Glint Color;2;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0.7490196,0.7490196,0.7490196,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;57;-176,240;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;58;-176,432;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-176,-240;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;-176,624;Inherit;True;Property;_TextureSample4;Texture Sample 4;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;38;-368,-512;Inherit;True;Stripes;-1;;1;8e73a71cdf24db740864b4c3f3357e7f;0;4;5;FLOAT;0.1;False;4;FLOAT;0;False;3;FLOAT;0.02;False;12;FLOAT;85.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;192,112;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;77;192,48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-48,-512;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;80;240,272;Inherit;False;Property;_OutlineColor;Outline Color;0;1;[HDR];Create;True;0;0;False;0;False;0,0,1.741101,0;0.2199275,0.3031433,0.9332059,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;368,48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;144,-336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;512,48;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;37;294,-260;Inherit;False;Multiply;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;672,-240;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;86;800,-240;Float;False;True;-1;2;ASEMaterialInspector;0;5;EnergyCell UI;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;74;0;65;0
WireConnection;75;0;65;0
WireConnection;70;0;65;0
WireConnection;32;0;25;0
WireConnection;73;1;75;0
WireConnection;71;1;65;0
WireConnection;72;0;74;0
WireConnection;60;1;70;0
WireConnection;63;1;73;0
WireConnection;39;0;32;0
WireConnection;62;1;72;0
WireConnection;61;1;71;0
WireConnection;56;0;6;0
WireConnection;56;1;60;0
WireConnection;57;0;6;0
WireConnection;57;1;61;0
WireConnection;58;0;6;0
WireConnection;58;1;62;0
WireConnection;5;0;6;0
WireConnection;59;0;6;0
WireConnection;59;1;63;0
WireConnection;38;4;39;0
WireConnection;76;0;56;4
WireConnection;76;1;57;4
WireConnection;76;2;58;4
WireConnection;76;3;59;4
WireConnection;77;0;5;4
WireConnection;26;0;22;0
WireConnection;26;1;38;0
WireConnection;78;0;77;0
WireConnection;78;1;76;0
WireConnection;20;0;26;0
WireConnection;20;1;5;0
WireConnection;79;0;78;0
WireConnection;79;1;80;0
WireConnection;37;0;20;0
WireConnection;37;1;5;0
WireConnection;81;0;37;0
WireConnection;81;1;79;0
WireConnection;86;0;81;0
ASEEND*/
//CHKSM=4A20BC4CC6E215A63B40EF1DE5A8D8FC1F305488