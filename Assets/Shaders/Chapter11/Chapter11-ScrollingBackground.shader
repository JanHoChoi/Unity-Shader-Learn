Shader "Unity Shaders Book/Chapter 11/Scrolling Background"
{
    Properties
    {
        _MainTex ("Base Layer", 2D) = "white" {}    // 较远的texture
        _DetailTex ("2nd Layer", 2D) = "white" {}   // 第二层texture
        _ScrollX ("Base Layer Scroll Speed", Float) = 1.0
        _Scroll2ndX ("2nd Layer Scroll Speed", Float) = 1.0
        _Multiplier ("Layer Multiplier", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScrollX, _Scroll2ndX, _Multiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2ndX, 0.0) * _Time.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
            }
            ENDCG
        }
    }
}
