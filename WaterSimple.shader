#warning Upgrade NOTE: unity_Scale shader variable was removed; replaced 'unity_Scale.w' with '1.0'

// https://catlikecoding.com/unity/tutorials/flow/looking-through-water/

Shader "Custom/WaterSimple"
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
		_FoamCutoff ("Foam Cutoff", Range(0,10)) = 0.78
		_FoamScale ("Foam Scale", Float) = 0.1
		_FoamEdgePower ("Foam Edge Power", Range(0,1)) = 1
		_FoamEdgeDistance ("Foam Edge Distance", Float) = 0.5
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_WaveData1 ("Wave Data 1 (x,y,scale,amp)", Vector) = (0,0,0.01,1)
		_WaveData2 ("Wave Data 2 (x,y,scale,amp)", Vector) = (0,0,0.05,1)
		_WaveData3 ("Wave Data 3 (x,y,scale,amp)", Vector) = (0,0,0.1,1)
		_WaterFogDensity ("Fog Density", Float) = 1
		_WaterFogColor ("Fog Color", Color) = (1,1,1,1)
		_RefractionStrength ("Refraction Strength", Range(0, 1)) = 0.055
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200
	
		GrabPass { "_WaterBackground" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha //finalcolor:ResetAlpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _WaveNormal1;
        sampler2D _WaveNormal2;
        sampler2D _WaveNormal3;
        sampler2D _WaveHeight1;
        sampler2D _WaveHeight2;
        sampler2D _WaveHeight3;
        sampler2D _Foam;
		sampler2D _CameraDepthTexture;
		float4 _CameraDepthTexture_TexelSize;
		sampler2D _WaterBackground;

        struct Input
        {
            float2 uv_MainTex;
			float4 screenPos;
        };

		// void ResetAlpha (Input IN, SurfaceOutputStandard o, inout fixed4 color) 
		// {
		// 	color.a = 1;
		// }

		float2 AlignWithGrabTexel (float2 uv)
		{
			if (_CameraDepthTexture_TexelSize.y < 0) {
				uv.y = 1 - uv.y;
			}			

			return
				(floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) *
				abs(_CameraDepthTexture_TexelSize.xy);
		}

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
		float _WaterFogDensity;
		fixed4 _WaterFogColor;
		float _RefractionStrength;
		float _FoamEdgePower;
		float _FoamEdgeDistance;

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
			fixed4 n1 = tex2D (_WaveNormal1, IN.uv_MainTex * _WaveData1.z * unity_ObjectToWorld[0][0] + p1);
			fixed4 n2 = tex2D (_WaveNormal2, IN.uv_MainTex * _WaveData2.z * unity_ObjectToWorld[0][0] + p2);
			fixed4 n3 = tex2D (_WaveNormal3, IN.uv_MainTex * _WaveData3.z * unity_ObjectToWorld[0][0] + p3);

			// black/white height
			fixed4 waveColor1 = tex2D (_WaveHeight1, IN.uv_MainTex * _WaveData1.z * unity_ObjectToWorld[0][0] + p1);
			fixed4 waveColor2 = tex2D (_WaveHeight2, IN.uv_MainTex * _WaveData2.z * unity_ObjectToWorld[0][0] + p2);
			fixed4 waveColor3 = tex2D (_WaveHeight3, IN.uv_MainTex * _WaveData3.z * unity_ObjectToWorld[0][0] + p3);

			// foam calculation
			float waveColorTotal = pow(waveColor1.x * _FoamCutoff * _WaveData1.w, 10) *
				pow(waveColor2.x * _FoamCutoff * _WaveData2.w, 10) *
				pow(waveColor3.x * _FoamCutoff * _WaveData3.w, 10);

			waveColorTotal = clamp(waveColorTotal, 0, 1);

			// foam velocity
			float2 foamVelocity = ( (_WaveData1.x + _WaveData2.x + _WaveData3.x) * 0.33,
					(_WaveData1.y + _WaveData2.y + _WaveData3.y) * 0.33
				);
			// foam position
			float2 foamPosition = foamVelocity * _Time.y;

			// foam texture
			fixed4 foam = tex2D (_Foam, IN.uv_MainTex * _FoamScale * unity_ObjectToWorld[0][0] + foamPosition) * waveColorTotal;

			// wave emission
			fixed4 waveEmit1 = lerp(_WaterFogColor, _Color, 0.5) * pow(waveColor1 * _WaveData1.w, 2);
			fixed4 waveEmit2 = lerp(_WaterFogColor, _Color, 0.5) * pow(waveColor2 * _WaveData2.w, 2);
			fixed4 waveEmit3 = lerp(_WaterFogColor, _Color, 0.5) * pow(waveColor3 * _WaveData3.w, 2);

			// water fog / background rendering
			float2 uvOffset = (UnpackScaleNormal(n1, _WaveData1.w) + UnpackScaleNormal(n2, _WaveData2.w) + UnpackScaleNormal(n3, _WaveData3.w)).xy;
			uvOffset *= _RefractionStrength;
			uvOffset.y *= _CameraDepthTexture_TexelSize.z * abs(_CameraDepthTexture_TexelSize.y);
			float2 uv = AlignWithGrabTexel((IN.screenPos.xy + uvOffset) / IN.screenPos.w);
			if (_CameraDepthTexture_TexelSize.y < 0) {
					uv.y = 1 - uv.y;
				}
			float backgroundDepth =
				LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
			float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(IN.screenPos.z);
			float depthDifference = (backgroundDepth - surfaceDepth);

			uvOffset *= saturate(depthDifference);
			uv = AlignWithGrabTexel((IN.screenPos.xy + uvOffset) / IN.screenPos.w);
			backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
			depthDifference = backgroundDepth - surfaceDepth;
			
			float fogFactor = exp2(-_WaterFogDensity * depthDifference);
			// water background
			float3 backgroundColor = tex2D(_WaterBackground, uv).rgb;

			// edge foam
			fixed4 foamEdge = clamp(tex2D (_Foam, IN.uv_MainTex * _FoamScale * unity_ObjectToWorld[0][0] + foamPosition), 0.25, 1) * ((1 - depthDifference / _FoamEdgeDistance)) * _FoamEdgePower;

			// apply
			o.Albedo = foam + clamp(foamEdge, 0, 1);
			o.Emission = clamp(lerp(_WaterFogColor + (waveEmit1 + waveEmit2 + waveEmit3) * 0.06, backgroundColor, fogFactor) + 0.25 * foam + 0.25 * clamp(foamEdge, 0, 0.25), 0, 1);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness - waveColorTotal - clamp((1 - depthDifference / _FoamEdgeDistance) * _FoamEdgePower, 0, 1);
            o.Alpha = _Color.a;
			o.Normal = UnpackScaleNormal(n1, _WaveData1.w) + UnpackScaleNormal(n2, _WaveData2.w) + UnpackScaleNormal(n3, _WaveData3.w);
        }
        ENDCG
    }
    //FallBack "Diffuse"
}
