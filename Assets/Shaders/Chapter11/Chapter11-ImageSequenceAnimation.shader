Shader "Unity Shaders Book/Chapter 11/Image Sequence Anim"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Image Sequence", 2D) = "white" {}
        _HorizontalAmount("Horizontal Amount", Float) = 4
        _VerticalAmount("Vertical Amount", Float) = 4
        _Speed("Speed", Range(1, 100)) = 30
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

        Pass
        {
            Tags {"LightMode"="ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount, _VerticalAmount, _Speed;

            v2f vert(a2v v)
            {
                v2f output;
                output.pos = UnityObjectToClipPos(v.vertex);
                output.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return output;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                float time = floor(_Time.y * _Speed);   // floor得到一个整数
                float row = floor(time / _HorizontalAmount);    // 行索引(第几行)
                float column = time - row * _HorizontalAmount;  // 列索引(第几列)

                half2 uv = i.uv + half2(column, -row);
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;    // /=是做一个映射的效果,比如把uv.x从[0,1]映射到[0, 1/col]之中
            
                fixed4 color = tex2D(_MainTex, uv);
                color.rgb *= _Color;
                return color;
            }
            ENDCG
        }
    }
}
