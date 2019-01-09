// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Tall_Vegetation" {

    Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor ("Color", Color) = (1,1,1,1)
		_MinY("Minimum Y Value", float) = 0.0 
		_NormalY("Normalize Y Value", float) = 1 

		_turb ("Turbulence", float) = 1

		_xScale ("X Amount", Range(-1,1)) = 0.5
		_yScale ("Y Amount", Range(-1,1)) = 0.5
		_zScale ("Z Amount", Range(-1,1)) = 0.5

		_Scale("Effect Scale", float) = 1.0 
		_Speed("Effect Speed", float) = 1.0 
    }


    SubShader {
		Tags { "RenderType" = "Opaque" }

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		#pragma target 3.0
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainColor;
		float _MinY;
		float _NormalY;
		float _turb;
		float _xScale;
		float _yScale;
		float _zScale;
		float _Scale;
		float _Speed;
		float _Amount;

		struct Input
		{
			float2 uv_MainTex;
		};

		void vert (inout appdata_full v)
		{
			float num = (v.vertex.y - _MinY) / _NormalY;

			if (num > 0.0) {
				float3 worldPos = mul (unity_ObjectToWorld, v.vertex).xyz * _turb;
				float x = sin(worldPos.x + (_Time.y*_Speed)) * num * _Scale * 0.01;
				float y = sin(worldPos.y + (_Time.y*_Speed)) * num * _Scale * 0.01;
				float z = sin(worldPos.z + (_Time.y*_Speed)) * num * _Scale * 0.01;

				v.vertex.x += x * _xScale;
				v.vertex.y += y * _yScale;
				v.vertex.z += z * _zScale;
			}
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = _MainColor * tex2D(_MainTex, IN.uv_MainTex).rgb;
		}

		ENDCG

	} 
}