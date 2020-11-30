// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 15/Water Wave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (0, 0.15, 0.115, 1)
        _WaveMap ("Wave Map",2D) = "bump" {}
        _Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
        _WaveXSpeed ("Wave Horizontal Speed", Range(-0.1, 0.1)) = 0.01
        _WaveYSpeed ("Wave Vertical Speed", Range(-0.1, 0.1)) = 0.01
        _Distortion ("Distortion", Range(0, 100)) = 10
    }
    SubShader
    {
    	Tags {"Queue"="Transparent" "RenderType"="Opaque"}

        GrabPass {"_RefractionTex"}

        Pass
        {
        	CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _WaveMap;
            float4 _WaveMap_ST;
            samplerCUBE _Cubemap;
            fixed _WaveXSpeed;
            fixed _WaveYSpeed;
            float _Distortion;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            struct a2v
            {
            	float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
            	float4 pos : SV_POSITION;
            	float4 scrPos : TEXCOORD0;
            	float4 uv : TEXCOORD1;
            	float4 TtoW0 : TEXCOORD2;
            	float4 TtoW1 : TEXCOORD3;
            	float4 TtoW2 : TEXCOORD4;
            };

            v2f vert(a2v v)
            {
            	v2f o;
            	o.pos = UnityObjectToClipPos(v.vertex);

                o.scrPos = ComputeGrabScreenPos(o.pos);

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
            	float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
            	fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
            	float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);

            	// 计算切线空间的法线
            	fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
            	fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
            	fixed3 bump = normalize(bump1 + bump2); // 模拟两层水波流动

            	float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;  // 模拟折射
            	i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;  // 深度越大,折射效果越明显
            	fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;  // 透视除法,再取样

            	bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));  // 把法线从切线空间转移到世界空间
            	fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
            	fixed3 reflDir = reflect(-viewDir, bump);  // 根据法线方向和视线方向,算出反射方向(viewDir原本方向由顶点指向摄像机)
            	fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb * _Color.rgb;

            	fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4); 
            	// 当视线和法线垂直时,类比湖边的人看远处的湖水,全是反射,此时fresnel系数很大
            	// 当视线与法线夹角很小时,类比湖边的人看脚下的水,基本没有反射,此时fresnel系数很小
            	// 所以fresnel系数与refl反射相乘,(1-fresnel)与refr折射相乘
            	fixed3 finalColor = fresnel * reflCol + (1 - fresnel) * refrCol;
            	return fixed4(finalColor, 1);

            }

            ENDCG
        }
    }
}
