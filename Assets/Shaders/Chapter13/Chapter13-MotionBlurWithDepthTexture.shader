Shader "Unity Shaders Book/Chapter 13/Motion Blur With Depth Texture"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {

        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _CurrentViewProjectionInverseMatrix;
        float4x4 _PreviousViewProjectionMatrix;
        half _BlurSize;

        struct v2f{
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                o.uv_depth.y = 1 - o.uv_depth.y;
            #endif
            return o;
        }

        fixed4 frag(v2f i) : SV_Target {

            // 对深度纹理取样
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);

            // 算出NDC坐标H, 其中x和y由uv映射回NDC坐标系的[-1,1], z通过公式用d计算, w都是1
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);

            // 根据NDC坐标,算回去世界坐标 证明:http://feepingcreature.github.io/math.html
            float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
            float4 worldPos = D / D.w;

            // 计算当前NDC坐标和上一帧NDC坐标
            float4 currentPos = H;
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
            previousPos /= previousPos.w;

            float2 velocity = (currentPos.xy - previousPos.xy) / 7.0f;  // 下文for循环中uv+=两次velocity * _BlurSize, 所以velocity也配合,所以/2.0f

            float2 uv = i.uv;
            float4 color = tex2D(_MainTex, uv);
            uv += velocity * _BlurSize;
            for(int it = 1; it < 8; it++, uv += velocity * _BlurSize)
            {
                float4 currentColor = tex2D(_MainTex, uv);
                color += currentColor;
            }
            color /= 8;

            return fixed4(color.rgb, 1.0);

        }

        ENDCG

        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
                
            ENDCG
        }
    }
    Fallback Off
}
