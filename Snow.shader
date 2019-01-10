Shader "Custom/Snow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

		_SnowColor("Snow Color", Color) = (1,1,1,1)
		_SnowTex("Snow (RGB)", 2D) = "white" {}
		_SnowAngle("Snow Angle (Deg)", Range(0, 359)) = 10
		_SnowDirection("Snow Direction", Vector) = (0,-1,0,0)
		_SnowMask("Snow Mask (A)", 2D) = "white" {}
    }



    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0 


		sampler2D _MainTex;
        fixed4 _Color;

		fixed4 _SnowColor;
		sampler2D _SnowTex;
		half _SnowAngle;
		fixed3 _SnowDirection;
		sampler2D _SnowMask;



		struct Input
        {
            float2 uv_MainTex;
			float3 worldPos;
        };



		fixed getMagnitude(fixed3 vec) 
		{
			return sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z);
		}



        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			// get normal
			fixed3 norm = -1 * WorldNormalVector(IN, o.Normal);

			// get angle
			float angle = acos( dot(norm, _SnowDirection) / (getMagnitude(_SnowDirection) * getMagnitude(norm)) ) * 180 / 3.14f;

			// get alpha from mask, needs to be 0 or 1
			half mask = tex2D(_SnowMask, IN.uv_MainTex).a;
			

			if (angle < _SnowAngle && mask > .5f)
			{
				// draw snow
				o.Albedo = tex2D(_SnowTex, IN.uv_MainTex) * _SnowColor;
			}
			else 
			{
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
			}			
        }
        ENDCG
    }
    FallBack "Diffuse"
}
