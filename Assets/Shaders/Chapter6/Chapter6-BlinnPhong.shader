Shader "Unity Shaders Book/Chapter 6/Chapter6-BlinnPhong"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20 
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Lighting.cginc"

                fixed4 _Diffuse;
                fixed4 _Specular;
                float _Gloss;

                struct a2v {
                    float4 vertex : POSITION;   // 顶点位置
                    float3 normal : NORMAL;     // 顶点法线方向
                };

                struct v2f {
                    float4 pos : SV_POSITION;   // 裁剪空间坐标
                    float3 worldNormal : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                };
                
                v2f vert(a2v v) {
                    v2f o;
                    // 从模型空间转移到裁剪空间坐标
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target {
                    // 获得环境光 
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                    fixed3 worldNormal = normalize(i.worldNormal);
                    // 获得顶点指向光源的向量
                    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    // 计算漫反射
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                    // 计算高光反射
                    // 反射方向
                    fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                    fixed3 h = normalize(worldLightDir + worldViewDir);

                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, h)), _Gloss);
                    fixed3 color = ambient + diffuse + specular;
                    return fixed4(color, 1.0);
                }
                
            ENDCG
        }
    }
    Fallback "Specular"
}
