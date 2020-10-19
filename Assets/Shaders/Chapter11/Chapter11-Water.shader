﻿Shader "Unity Shaders Book/Chapter 11/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
        _Magnitude("Distortion Magnitude", Float) = 1 // 振幅
        _Frequency("Distortion Frequency", Float) = 1 // 频率
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
        _Speed ("Speed", Float) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True" }

        Pass
        {
        	Tags { "Lightning"="ForwardBase" }
        	ZWrite Off
        	Blend SrcAlpha OneMinusSrcAlpha
        	Cull Off

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
            	float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Magnitude, _Frequency, _InvWaveLength, _Speed;

            v2f vert (a2v v)
            {
                v2f o;
                float4 offset;
                offset.yzw = float3(0, 0, 0);
                offset.x = _Magnitude * sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.z * _InvWaveLength);	// wave大 InvWave小 则相邻x相差小 看起来水波更长更缓和
                o.position = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv += float2(0, _Time.y * _Speed);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target{
            
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }
}
