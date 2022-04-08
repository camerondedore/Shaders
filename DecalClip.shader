Shader "Custom/DecalClip"
{
    Properties
    {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ClipAlpha ("Alpha Clip", Range(0,1)) = 0.5
		_ZDistance("Z Distance", Float) = 0.1
    }
    SubShader
    {
		Tags { "RenderType"="Fade"}
        LOD 200
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass { "_DecalBackground" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha:fade  //finalcolor:ResetAlpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D _CameraDepthTexture;
		float4 _CameraDepthTexture_TexelSize;
		sampler2D _DecalBackground;

        struct Input
        {
            float2 uv_MainTex;
			float4 screenPos;
			float3 viewDir;
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

        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;
        half _ClipAlpha;
		float _ZDistance;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			// clip alpha
			clip(tex2D(_MainTex, IN.uv_MainTex).a - _ClipAlpha);

			// background
			float2 uv = AlignWithGrabTexel((IN.screenPos.xy) / IN.screenPos.w);
			if (_CameraDepthTexture_TexelSize.y < 0) {
					uv.y = 1 - uv.y;
				}
			float backgroundDepth =
				LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
			float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(IN.screenPos.z);
			float depthDifference = (backgroundDepth - surfaceDepth);

			// the triangle used to find the distance (r) between the decal and the wall is
			// found using r = depthDifference * viewDir (dot) o.Normal
			// this is to account for the camera view's depth
			//float distance = depthDifference * dot(normalize(IN.viewDir), o.Normal);

			uv = AlignWithGrabTexel((IN.screenPos.xy) / IN.screenPos.w);
			backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
			depthDifference = backgroundDepth - surfaceDepth;

			// Z check and clip
			//clip(_ZDistance - distance);
			clip(_ZDistance - depthDifference);

			// apply
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
			//o.Alpha = tex2D(_MainTex, IN.uv_MainTex).a;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    //FallBack "Diffuse"
}
