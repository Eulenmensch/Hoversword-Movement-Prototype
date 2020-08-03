// Upgrade NOTE: upgraded instancing buffer 'FlipBookTrails' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FlipBookTrails"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Flipbook("Flipbook", 2D) = "white" {}
		_ScrollSpeed("ScrollSpeed", Float) = 0
		_SpriteSheetRows("SpriteSheetRows", Int) = 2
		_SpriteSheetColumns("SpriteSheetColumns", Int) = 2
		_Color("Color", Color) = (0,0,0,0)
		_EmissionIntensity("EmissionIntensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Flipbook;
		uniform int _SpriteSheetColumns;
		uniform int _SpriteSheetRows;
		uniform float _ScrollSpeed;
		uniform float _Cutoff = 0.5;

		UNITY_INSTANCING_BUFFER_START(FlipBookTrails)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
#define _Color_arr FlipBookTrails
			UNITY_DEFINE_INSTANCED_PROP(float, _EmissionIntensity)
#define _EmissionIntensity_arr FlipBookTrails
		UNITY_INSTANCING_BUFFER_END(FlipBookTrails)

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles17 = (float)_SpriteSheetColumns * (float)_SpriteSheetRows;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset17 = 1.0f / (float)_SpriteSheetColumns;
			float fbrowsoffset17 = 1.0f / (float)_SpriteSheetRows;
			// Speed of animation
			float fbspeed17 = _Time.y * _ScrollSpeed;
			// UV Tiling (col and row offset)
			float2 fbtiling17 = float2(fbcolsoffset17, fbrowsoffset17);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex17 = round( fmod( fbspeed17 + 0.0, fbtotaltiles17) );
			fbcurrenttileindex17 += ( fbcurrenttileindex17 < 0) ? fbtotaltiles17 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox17 = round ( fmod ( fbcurrenttileindex17, (float)_SpriteSheetColumns ) );
			// Multiply Offset X by coloffset
			float fboffsetx17 = fblinearindextox17 * fbcolsoffset17;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy17 = round( fmod( ( fbcurrenttileindex17 - fblinearindextox17 ) / (float)_SpriteSheetColumns, (float)_SpriteSheetRows ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy17 = (int)((float)_SpriteSheetRows-1) - fblinearindextoy17;
			// Multiply Offset Y by rowoffset
			float fboffsety17 = fblinearindextoy17 * fbrowsoffset17;
			// UV Offset
			float2 fboffset17 = float2(fboffsetx17, fboffsety17);
			// Flipbook UV
			half2 fbuv17 = i.uv_texcoord * fbtiling17 + fboffset17;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode19 = tex2D( _Flipbook, fbuv17 );
			float4 _Color_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color);
			float _EmissionIntensity_Instance = UNITY_ACCESS_INSTANCED_PROP(_EmissionIntensity_arr, _EmissionIntensity);
			o.Emission = ( tex2DNode19 * _Color_Instance * _EmissionIntensity_Instance ).rgb;
			o.Alpha = 1;
			clip( tex2DNode19.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
-1862;63;1920;1023;936.9186;864.7896;1.838611;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;4;-320.6191,104.6911;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-320.6191,-7.308942;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;11;-320.6191,168.691;Inherit;False;Property;_SpriteSheetColumns;SpriteSheetColumns;4;0;Create;True;0;0;False;0;False;2;2;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;12;-320.6191,232.691;Inherit;False;Property;_SpriteSheetRows;SpriteSheetRows;3;0;Create;True;0;0;False;0;False;2;2;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-320.6191,296.6911;Inherit;False;Property;_ScrollSpeed;ScrollSpeed;2;0;Create;True;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;80,-240;Inherit;True;Property;_Flipbook;Flipbook;1;0;Create;True;0;0;False;0;False;None;1eb4022ffe2a16842a9c260153553a90;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;17;-0.61904,8.691055;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;19;400,-16;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;14;494,184;Inherit;False;InstancedProperty;_Color;Color;5;0;Create;True;0;0;False;0;False;0,0,0,0;0,0.4309109,0.7529412,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;496,368;Inherit;False;InstancedProperty;_EmissionIntensity;EmissionIntensity;6;0;Create;True;0;0;False;0;False;0;3.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;840,38;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;32;1157,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;FlipBookTrails;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;18;0
WireConnection;17;1;11;0
WireConnection;17;2;12;0
WireConnection;17;3;13;0
WireConnection;17;5;4;0
WireConnection;19;0;3;0
WireConnection;19;1;17;0
WireConnection;15;0;19;0
WireConnection;15;1;14;0
WireConnection;15;2;16;0
WireConnection;32;2;15;0
WireConnection;32;10;19;4
ASEEND*/
//CHKSM=A325D6673EB67FE481981BED817F0D5DD6A08051