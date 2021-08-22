Shader "Custom/RimLight"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Metallic ("Metallic (RGB), Smoothness (A)", 2D) = "black" {}
		_RimColor ("Rim Color", Color) = (1, 1, 1, 1)
		_RimStrength ("Rim Strength", float) = 0.5
		_RimSharpness ("Rim Sharpness", Range(0, 0.5)) = 0.1
		_RimDistance ("Rim Distance", float) = 1
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
			float3 viewDir;
        };

        sampler2D _MainTex;
        sampler2D _Metallic;
        fixed4 _RimColor;
		float _RimStrength;
		float _RimSharpness;
		float _RimDistance;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			// calculate rim
			// lambertian coefficient is normally = surface normal DOT light direction
			// but we're using the view normal for rim
			float lambertCeofficient = saturate(dot(normalize(IN.viewDir), o.Normal));
			half rim = _RimDistance - lambertCeofficient;

            o.Albedo = tex2D (_MainTex, IN.uv_MainTex);
            o.Metallic = tex2D (_Metallic, IN.uv_MainTex).rgb;
            o.Smoothness = tex2D (_Metallic, IN.uv_MainTex).a;
			o.Emission = smoothstep(_RimSharpness, 1 - _RimSharpness, rim) * _RimStrength * _RimColor;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
