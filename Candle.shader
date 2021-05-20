Shader "Custom/Candle"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Emission ("Emission", 2D) = "white" {}
		_EmissionColor ("Emission Color", Color) = (1,1,1,1)
		_EmissionStrength ("Emission Strength", Range(0, 10)) = 1
		_FlickerSpeed ("Flicker Speed", Range(0, 10)) = 1
		_FlickerMin ("Flicker Minimum", Range(0, 1)) = 0
		_FlickerTurb ("Flicker Turbulence", Range(0, 20)) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _Emission;

        struct Input
        {
            float2 uv_MainTex;
			float3 position;
        };

        fixed4 _Color;
        fixed4 _EmissionColor;
        float _EmissionStrength;
        float _FlickerSpeed;
        float _FlickerMin;
        float _FlickerTurb;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

		void vert(inout appdata_full v, out Input o)
		{
			// get position to pass to surf
			UNITY_INITIALIZE_OUTPUT(Input, o);
            o.position = mul(unity_ObjectToWorld, v.vertex).xyz;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float positionOffset = (IN.position.x + IN.position.y + IN.position.z) * _FlickerTurb;

			// calculate flicker
			float flicker = sin(_Time.y * _FlickerSpeed + positionOffset) 
				* sin(0.24 * _Time.y * _FlickerSpeed + 1 + positionOffset) 
				* sin(2 * _Time.y * _FlickerSpeed + 2 + positionOffset) * 0.5 + 0.5;

			flicker = clamp(flicker, _FlickerMin, 1);
			
			// apply
            o.Albedo = _Color.rgb;
			o.Emission = tex2D(_Emission, IN.uv_MainTex) * _EmissionColor * _EmissionStrength * flicker;
            o.Alpha = _Color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
