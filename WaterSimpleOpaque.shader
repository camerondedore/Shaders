Shader "Custom/WaterSimpleOpaque"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_WaveNormal1 ("Wave Normal 1", 2D) = "white" {}
		_WaveNormal2 ("Wave Normal 2", 2D) = "white" {}
		_WaveNormal3 ("Wave Normal 3", 2D) = "white" {}
		_WaveHeight1 ("Wave Height 1", 2D) = "white" {}
		_WaveHeight2 ("Wave Height 2", 2D) = "white" {}
		_WaveHeight3 ("Wave Height 3", 2D) = "white" {}
		_Foam ("Wave Foam", 2D) = "white" {}
		_FoamCutoff ("Foam Cutoff", Range(0,10)) = 1
		_FoamScale ("Foam Scale", Float) = 30
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_WaveData1 ("Wave Data 1 (x,y,scale,amp)", Vector) = (0,0,10,1)
		_WaveData2 ("Wave Data 2 (x,y,scale,amp)", Vector) = (0,0,10,1)
		_WaveData3 ("Wave Data 3 (x,y,scale,amp)", Vector) = (0,0,10,1)
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

        sampler2D _WaveNormal1;
        sampler2D _WaveNormal2;
        sampler2D _WaveNormal3;
        sampler2D _WaveHeight1;
        sampler2D _WaveHeight2;
        sampler2D _WaveHeight3;
        sampler2D _Foam;

        struct Input
        {
            float2 uv_MainTex;
        };

		// float Magnitude(float4 v)
		// {
		// 	return sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
		// }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		float4 _WaveData1;
		float4 _WaveData2;
		float4 _WaveData3;
		float _FoamScale;
		float _FoamCutoff;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			// normal map positions
			float2 p1 = float2(_WaveData1.x * _Time.y, _WaveData1.y * _Time.y);
			float2 p2 = float2(_WaveData2.x * _Time.y, _WaveData2.y * _Time.y);
			float2 p3 = float2(_WaveData3.x * _Time.y, _WaveData3.y * _Time.y);

			// normal map texture
			fixed4 n1 = tex2D (_WaveNormal1, IN.uv_MainTex * _WaveData1.z + p1);
			fixed4 n2 = tex2D (_WaveNormal2, IN.uv_MainTex * _WaveData2.z + p2);
			fixed4 n3 = tex2D (_WaveNormal3, IN.uv_MainTex * _WaveData3.z + p3);

			// black/white height
			fixed4 waveColor1 = tex2D (_WaveHeight1, IN.uv_MainTex * _WaveData1.z + p1);
			fixed4 waveColor2 = tex2D (_WaveHeight2, IN.uv_MainTex * _WaveData2.z + p2);
			fixed4 waveColor3 = tex2D (_WaveHeight3, IN.uv_MainTex * _WaveData3.z + p3);

			// foam calculation
			float waveColorTotal = pow(waveColor1 * _FoamCutoff * _WaveData1.w, 10) *
				pow(waveColor2 * _FoamCutoff * _WaveData2.w, 10) *
				pow(waveColor3 * _FoamCutoff * _WaveData3.w, 10);

			waveColorTotal = clamp(waveColorTotal, 0, 1);

			// foam velocity
			float2 foamVelocity = ( (_WaveData1.x + _WaveData2.x + _WaveData3.x) * 0.33,
					(_WaveData1.y + _WaveData2.y + _WaveData3.y) * 0.33
				);
			// foam position
			float2 foamPosition = foamVelocity * _Time.y;

			// foam texture
			fixed4 foam = tex2D (_Foam, IN.uv_MainTex * _FoamScale + foamPosition) * waveColorTotal;

			// wave emission
			fixed4 waveEmit1 = _Color * pow(waveColor1 * _WaveData1.w, 2);
			fixed4 waveEmit2 = _Color * pow(waveColor2 * _WaveData2.w, 2);
			fixed4 waveEmit3 = _Color * pow(waveColor3 * _WaveData3.w, 2);

			// apply
			o.Albedo = _Color + foam;
			o.Emission = (waveEmit1 + waveEmit2 + waveEmit3) * 0.06 + 0.25 * foam;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness - waveColorTotal;
            o.Alpha = _Color.a;
			o.Normal = UnpackScaleNormal(n1, _WaveData1.w) + UnpackScaleNormal(n2, _WaveData2.w) + UnpackScaleNormal(n3, _WaveData3.w);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
