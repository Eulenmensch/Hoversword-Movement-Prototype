// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FlipBookTrails"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_Flipbook("Flipbook", 2D) = "white" {}
		_ScrollSpeed("ScrollSpeed", Float) = 0
		_SpriteSheetRows("SpriteSheetRows", Int) = 2
		_SpriteSheetColumns("SpriteSheetColumns", Int) = 2
		_Color("Color", Color) = (0,0,0,0)
		_EmissionIntensity("EmissionIntensity", Float) = 0

	}


	Category 
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha One
			ColorMask RGB
			Cull Off
			Lighting Off 
			ZWrite Off
			ZTest LEqual
			
			Pass {
			
				CGPROGRAM
				
				#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
				#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
				#endif
				
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_instancing
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				#include "UnityShaderVariables.cginc"


				#include "UnityCG.cginc"

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
					
				};
				
				
				#if UNITY_VERSION >= 560
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				#else
				uniform sampler2D_float _CameraDepthTexture;
				#endif

				//Don't delete this comment
				// uniform sampler2D_float _CameraDepthTexture;

				uniform sampler2D _MainTex;
				uniform fixed4 _TintColor;
				uniform float4 _MainTex_ST;
				uniform float _InvFade;
				uniform sampler2D _Flipbook;
				uniform int _SpriteSheetColumns;
				uniform int _SpriteSheetRows;
				uniform float _ScrollSpeed;
				uniform float4 _Color;
				uniform float _EmissionIntensity;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					

					v.vertex.xyz +=  float3( 0, 0, 0 ) ;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = v.texcoord;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag ( v2f i  ) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( i );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( i );

					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif

					float2 uv018 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
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
					half2 fbuv17 = uv018 * fbtiling17 + fboffset17;
					// *** END Flipbook UV Animation vars ***
					

					fixed4 col = ( tex2D( _Flipbook, fbuv17 ) * _Color * _EmissionIntensity );
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG 
			}
		}	
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18100
2810;499.3333;1145;562;-73.64935;69.65402;1;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;4;-320.6191,104.6911;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-320.6191,-7.308942;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;11;-320.6191,168.691;Inherit;False;Property;_SpriteSheetColumns;SpriteSheetColumns;3;0;Create;True;0;0;False;0;False;2;1;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;12;-320.6191,232.691;Inherit;False;Property;_SpriteSheetRows;SpriteSheetRows;2;0;Create;True;0;0;False;0;False;2;3;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-320.6191,296.6911;Inherit;False;Property;_ScrollSpeed;ScrollSpeed;1;0;Create;True;0;0;False;0;False;0;5.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;80,-240;Inherit;True;Property;_Flipbook;Flipbook;0;0;Create;True;0;0;False;0;False;None;207602659ff2c304e84637a6413bcbc4;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;17;-0.61904,8.691055;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;14;480,192;Inherit;False;Property;_Color;Color;4;0;Create;True;0;0;False;0;False;0,0,0,0;0.48131,0.9811321,0.9709787,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;496,368;Inherit;False;Property;_EmissionIntensity;EmissionIntensity;5;0;Create;True;0;0;False;0;False;0;6.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;400,-16;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;803,122;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1093,94;Float;False;True;-1;2;ASEMaterialInspector;0;8;FlipBookTrails;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;8;5;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;True;True;True;True;False;0;False;-1;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;0
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
WireConnection;1;0;15;0
ASEEND*/
//CHKSM=128E386618F9F48F6943681B7AC8F846A3DA6CF2