Shader "Custom/WindowParallax"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Metallic ("Metallic", 2D) = "black" {}

		_DeepEmit ("Deep Emission", 2D) = "white" {}
		_DeepEmitValue ("Deep Emission Value", Range(0.0, 5.0)) = 1.0

		_Depth ("Depth", Float) = 0.5
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

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_DeepTex;
			float3 viewDir;
			//float worldPos;
        };

		sampler2D _MainTex;
		sampler2D _Metallic;
		sampler2D _DeepEmit;
		half _DeepEmitValue;
		half _Depth;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			//float camDist = distance(IN.worldPos, _WorldSpaceCameraPos);

			// calculate parallax
			float2 offset = ParallaxOffset(1, _Depth, IN.viewDir);
			IN.uv_DeepTex.x -= offset.x;
			IN.uv_DeepTex.y -= offset.y;

			// get pixel coordinates for main texture
			half4 m = tex2D (_MainTex, IN.uv_MainTex);

			// get pixel coordinates for deep emit texture
			half4 de = tex2D (_DeepEmit, IN.uv_DeepTex - 0.5);


            o.Albedo = m.rgb;
            o.Metallic = tex2D (_Metallic, IN.uv_MainTex).r;
            o.Smoothness = tex2D (_Metallic, IN.uv_MainTex).a;
            o.Emission = (de.rgb - m.a) * _DeepEmitValue;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
