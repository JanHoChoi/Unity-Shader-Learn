Shader "Unity Shaders Book/Chapter 13/Flg With Depth Texture"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _FogDensity ("Fog Density", Float) = 1.0
        _FogColor ("Fog Color", Color) = (1,1,1,1)
        _FogStart ("Fog Start", Float) = 0.0
        _FogEnd ("Fog End", Float) = 1.0
    }
    SubShader
    {

        CGINCLUDE

        #include "UnityCG.cginc"

        float4x4 _FrustumCornersRay;

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDensity;
        fixed4 _FogColor;
        float _FogStart, _FogEnd;

        struct v2f{
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
            float4 interpolatedRay : TEXCOORD2;
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

            // 这里不用担心计算导致性能,因为顶点只有4个,同时也不用担心x=0.5之类的边界值
            int index = 0;
            if (v.texcoord.x < 0.5 && v.texcoord.y > 0.5)       // 左上角
                index = 0;
            else if(v.texcoord.x > 0.5 && v.texcoord.y > 0.5)   // 右上角
                index = 1;
            else if(v.texcoord.x < 0.5 && v.texcoord.y < 0.5)   // 左下角
                index = 2;
            else if(v.texcoord.x > 0.5 && v.texcoord.y < 0.5)   // 右下角
                index = 3;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                index = (index + 2) % 4;
            #endif

            o.interpolatedRay = _FrustumCornersRay[index];
            return o;
        }

        fixed4 frag(v2f i) : SV_Target {

            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
            float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

            float fogFactor = (_FogStart - worldPos.y) / (_FogStart - _FogEnd); // 雾效因子,越小则雾越大
            fogFactor = saturate(fogFactor * _FogDensity);

            fixed4 finalColor = tex2D(_MainTex, i.uv);
            finalColor.rgb = lerp(_FogColor.rgb, finalColor.rgb, fogFactor);

            return finalColor;
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
