// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
// from 2017.1.1 built-in Sprites-Diffuse Shader
// and https://forum.unity.com/threads/shader-moving-trees-grass-in-wind-outside-of-terrain.230911/
Shader "Custom/Water" {

    Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor ("Color", Color) = (1,1,1,1)

		_turb ("Turbulence", float) = 1

		_dir1 ("First Wave Direction", Vector) = (0, 0, 0)
		_dir2 ("Second Wave Direction", Vector) = (0, 0, 0)

		_Scale("Effect Scale", float) = 1.0 
		_Speed("Effect Speed", float) = 1.0 

		_Soft("Soften", float) = 1.0 
    }


    SubShader {
		Tags { "RenderType" = "Opaque" }

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		#pragma target 3.0
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainColor;
		float _turb;
		float3 _dir1;
		float3 _dir2;
		float _Scale;
		float _Speed;
		float _Amount;
		float _Soft;

		struct Input
		{
			float2 uv_MainTex;
		};

		void vert (inout appdata_full v)
		{
			float3 worldPos = mul (unity_ObjectToWorld, v.vertex).xyz * _turb;
			float y = sin(worldPos.x * _dir1.x + worldPos.y * _dir1.y + worldPos.z * _dir1.z + (_Time.y*_Speed)) + 
						sin(worldPos.x * _dir2.x + worldPos.y * _dir2.y + worldPos.z * _dir2.z + (_Time.y*_Speed)) +
						_Soft * sin(worldPos.x + worldPos.y + worldPos.z + (_Time.y*_Soft));

			v.vertex.y += y * _Scale * .5;			
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = _MainColor * tex2D(_MainTex, IN.uv_MainTex).rgb;
		}

		ENDCG

	} 
}