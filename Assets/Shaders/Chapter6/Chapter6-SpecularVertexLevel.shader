// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 6/Chapter6-SpecularVertexLevel"
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
                    fixed3 color : COLOR;       // 颜色
                };
                
                v2f vert(a2v v) {
                    v2f o;
                    // 从模型空间转移到裁剪空间坐标
                    o.pos = UnityObjectToClipPos(v.vertex);
                    // 获得环境光 
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                    // 把法线转换到世界空间下
                    fixed3 worldNormalDir = UnityObjectToWorldNormal(v.normal);
                    
                    // 获得顶点指向光源的向量
                    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                    // 计算漫反射
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormalDir, worldLight));
                    // 计算高光反射
                    // 反射方向
                    fixed3 lightReflectDir = normalize(reflect(-worldLight, worldNormalDir));
                    fixed3 worldViewDir = normalize(WorldSpaceViewDir(v.vertex));
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(lightReflectDir, worldViewDir)), _Gloss);
                    o.color = ambient + diffuse + specular;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target {
                    return fixed4(i.color, 1.0);
                }
                
            ENDCG
        }
    }
    Fallback "Specular"
}
