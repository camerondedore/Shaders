Shader "Custom/Candle"
{
    Properties
    {
        _MainTex("Base (RGBA)", 2D) = "white" {}
        _Emission ("Emission (r)", 2D) = "white" {}
		//_EmissionColor ("Emission Color", Color) = (1,1,1,1)
		_EmissionStrength ("Emission Strength", Range(0, 100)) = 1
		_FlickerSpeed ("Flicker Speed", Range(0, 10)) = 1
		_FlickerMin ("Flicker Minimum", Range(0, 1)) = 0
		_FlickerWorldUnit ("Flicker World Unit", Range(0, 1)) = 0.1
		_Smoothness ("Smoothness", Range(0, 1)) = 0

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

        struct Input
        {
            float2 uv_MainTex;
			float3 position;
        };

		sampler2D _MainTex;
        sampler2D _Emission;
        float _EmissionStrength;
        float _FlickerSpeed;
        float _FlickerMin;
        float _FlickerWorldUnit;
        float _Smoothness;

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
			// calculate fake noise using world position
			float worldUnitMult = 1 / _FlickerWorldUnit;
			float positionOffset = (IN.position.x * worldUnitMult) +
				(IN.position.y * worldUnitMult) + 
				(IN.position.z * worldUnitMult);

			// calculate flicker
			float flicker = sin(_Time.y * _FlickerSpeed + positionOffset) 
				* sin(0.24 * _Time.y * _FlickerSpeed + 1 + positionOffset) 
				* sin(2 * _Time.y * _FlickerSpeed + 2 + positionOffset) * 0.5 + 0.5;

			flicker = clamp(flicker, _FlickerMin, 1);
			
			// apply
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
			o.Emission = tex2D(_Emission, IN.uv_MainTex) * _EmissionStrength * flicker;
			o.Smoothness = _Smoothness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
