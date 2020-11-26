Shader "Custom/TallVegetation" 
{

	Properties
	{
		_MainTex("Base (RGBA)", 2D) = "white" {}
		_Cutoff("Cutoff", Range(0,1)) = .5
		_MainColor("Color", Color) = (1,1,1,1)
		_Smooth("Smoothness", Range(0,1)) = .5
		_Metal("Metallic", Range(0,1)) = .5
		_MinY("Minimum Y Value", float) = 0.0
		_NormalY("Normalize Y Value", float) = 1

		_turb("Turbulence", float) = 1

		_xScale("X Amount", Range(-1,1)) = 0.5
		_yScale("Y Amount", Range(-1,1)) = 0.5
		_zScale("Z Amount", Range(-1,1)) = 0.5

		_Scale("Effect Scale", float) = 1.0
		_Speed("Effect Speed", float) = 1.0
	}



	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		CGPROGRAM
		#pragma surface surf Standard vertex:vert addshadow
		#pragma target 3.0
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float _Cutoff;
		float4 _MainColor;
		float _Smooth;
		float _Metal;
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



		void vert(inout appdata_full v)
		{
			float num = (v.vertex.y - _MinY) / _NormalY;

			if (num > 0.0) {
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz * _turb;
				float x = sin(worldPos.x + (_Time.y*_Speed)) * num * _Scale * 0.01;
				float y = sin(worldPos.y + (_Time.y*_Speed)) * num * _Scale * 0.01;
				float z = sin(worldPos.z + (_Time.y*_Speed)) * num * _Scale * 0.01;

				v.vertex.x += x * _xScale;
				v.vertex.y += y * _yScale;
				v.vertex.z += z * _zScale;
			}
		}



		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			float4 tex = tex2D(_MainTex, IN.uv_MainTex);

			if (tex.a < _Cutoff) 
			{
				discard;
			}

			o.Albedo = _MainColor * tex.rgb;
			o.Smoothness = _Smooth;
			o.Metallic = _Metal;
		}

		ENDCG
	}
}