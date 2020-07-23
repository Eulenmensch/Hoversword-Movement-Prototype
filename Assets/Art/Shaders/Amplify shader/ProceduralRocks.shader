// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ProceduralRocks"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
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


		float3 modulo3( float3 divident , float3 divisor )
		{
			float3 positiveDivident = divident % divisor + divisor;
			return positiveDivident % divisor;
		}


		float rand3dTo1d( float3 value , float3 dotDir )
		{
			//make value smaller to avoid artefacts
				float3 smallValue = cos(value);
				//get scalar value from 3d vector
				float random = dot(smallValue, dotDir);
				//make value more random by making it bigger and then taking the factional part
				random = frac(sin(random) * 143758.5453);
				return random;
		}


		float rand1dTo1d( float value , float mutator )
		{
			float random = frac(sin(value + mutator) * 143758.5453);
				return random;
		}


		float rand3dTo1d1Param( float3 value )
		{
			float3 dotDir = float3(12.9898, 78.233, 37.719); 
			//make value smaller to avoid artefacts
				float3 smallValue = cos(value);
				//get scalar value from 3d vector
				float random = dot(smallValue, dotDir);
				//make value more random by making it bigger and then taking the factional part
				random = frac(sin(random) * 143758.5453);
				return random;
		}


		float3 rand3dTo3d( float3 value )
		{
			return float3(
					rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
					rand3dTo1d(value, float3(39.346, 11.135, 83.155)),
					rand3dTo1d(value, float3(73.156, 52.235, 09.151))
				);
		}


		float3 rand1dTo3d( float value )
		{
			return float3(
					rand1dTo1d(value, 3.9812),
					rand1dTo1d(value, 7.1536),
					rand1dTo1d(value, 5.7241)
				);
		}


		float3 voronoiNoise( float3 value , float3 period , float3 angleOffset )
		{
			float3 baseCell = floor(value);
							//first pass to find the closest cell
							float minDistToCell = 10;
							float3 toClosestCell;
							float3 closestCell;
							[unroll]
							for(int x1=-1; x1<=1; x1++){
								[unroll]
								for(int y1=-1; y1<=1; y1++){
									[unroll]
									for(int z1=-1; z1<=1; z1++){
										float3 cell = baseCell + float3(x1, y1, z1);
										float3 tiledCell = modulo3(cell, period);
										float3 cellPosition = cell + rand3dTo3d(tiledCell)*angleOffset;
										float3 toCell = cellPosition - value;
										float distToCell = length(toCell);
										if(distToCell < minDistToCell){
											minDistToCell = distToCell;
											closestCell = cell;
											toClosestCell = toCell;
										}
									}
								}
							}
							//second pass to find the distance to the closest edge
							float minEdgeDistance = 10;
							[unroll]
							for(int x2=-1; x2<=1; x2++){
								[unroll]
								for(int y2=-1; y2<=1; y2++){
									[unroll]
									for(int z2=-1; z2<=1; z2++){
										float3 cell = baseCell + float3(x2, y2, z2);
										float3 tiledCell = modulo3(cell, period);
										float3 cellPosition = cell + rand3dTo3d(tiledCell);
										float3 toCell = cellPosition - value;
										float3 diffToClosestCell = abs(closestCell - cell);
										bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
										if(!isClosestCell){
											float3 toCenter = (toClosestCell + toCell) * 0.5;
											float3 cellDifference = normalize(toCell - toClosestCell);
											float edgeDistance = dot(toCenter, cellDifference);
											minEdgeDistance = min(minEdgeDistance, edgeDistance);
										}
									}
								}
							}
							float random = rand3dTo1d1Param(closestCell);
							return float3(minDistToCell, random, minEdgeDistance);
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			c.rgb = 0;
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
			float3 ase_worldPos = i.worldPos;
			float2 temp_cast_0 = (ase_worldPos.y).xx;
			float3 appendResult14_g1 = (float3(temp_cast_0 , 4.83));
			float3 value5_g1 = ( appendResult14_g1 * 2.92 );
			float3 period5_g1 = float3( 4,4,4 );
			float3 angleOffset5_g1 = float3( 1.41,2.25,4.62 );
			float3 localvoronoiNoise5_g1 = voronoiNoise( value5_g1 , period5_g1 , angleOffset5_g1 );
			float3 break9_g1 = localvoronoiNoise5_g1;
			float3 temp_cast_1 = (break9_g1.y).xxx;
			o.Emission = temp_cast_1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
-1887;76;1920;1029;2339.488;644.3176;1.597464;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-1666.956,31.40961;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;1;-1399.884,18.14178;Inherit;True;VoronoiNoise3DTiled;-1;;1;73ed0a6f92eaf7a468d8a4b71f8f6990;0;5;19;FLOAT3;1.41,2.25,4.62;False;12;FLOAT2;0,0;False;13;FLOAT;4.83;False;18;FLOAT;2.92;False;17;FLOAT3;4,4,4;False;3;FLOAT;0;FLOAT;11;FLOAT;10
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ProceduralRocks;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;12;2;2
WireConnection;0;2;1;10
ASEEND*/
//CHKSM=AA30C7FC8B2CC61545A0FB3951DA52436EB5558F