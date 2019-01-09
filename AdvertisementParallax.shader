Shader "Custom/AdvertisementParallax" {



	Properties 
	{
		_MainTex ("Albedo (RGBA)", 2D) = "white" {}
		_MainEmit ("Main Emission", 2D) = "white" {}
		_MainEmitValue ("Main Emission Value", Range(0.0, 5.0)) = 1.0

		_DeepTex ("Deep (RGB)", 2D) = "black" {}
		_DeepEmit ("Deep Emission", 2D) = "white" {}
		_DeepEmitValue ("Deep Emission Value", Range(0.0, 5.0)) = 1.0

		_Depth ("Depth", Float) = 0.5
		_Scale ("Depth Scale", Float) = 0.5
	}



	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MainEmit;
		half _MainEmitValue;

		sampler2D _DeepTex;
		sampler2D _DeepEmit;
		half _DeepEmitValue;

		half _Depth;
		half _Scale;

		sampler2D _Blank;



		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_DeepTex;
			float3 viewDir;
		};



		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// calculate parallax
			float2 offset = ParallaxOffset(1, _Depth, IN.viewDir);
			IN.uv_DeepTex.x -= offset.x;
			IN.uv_DeepTex.y -= offset.y;

			// get pixel coordinates for main texture
			half4 m = tex2D (_MainTex, IN.uv_MainTex);
			half4 me = tex2D (_MainEmit, IN.uv_MainTex);

			// get pixel coordinates for deep texture
			half4 d = tex2D (_DeepTex, IN.uv_DeepTex * (1/_Scale) - .5 * (1/_Scale - 1));
			half4 de = tex2D (_DeepEmit, IN.uv_DeepTex * (1/_Scale) - .5 * (1/_Scale - 1));

			// render pixels
			o.Albedo = d.rgb * (1 - m.a) + m.rgb * m.a;
			o.Emission = de * _DeepEmitValue * (1 - m.a) + me * _MainEmitValue * m.a;
			o.Normal = UnpackNormal(tex2D(_Blank, IN.uv_DeepTex ));
		}

		ENDCG
	}

	FallBack "Diffuse"
}
