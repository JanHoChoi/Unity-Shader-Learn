Shader "Unity Shaders Book/Chapter 6/Chapter6-DiffuseVertexLevel"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
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
                    fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    //fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                    
                    // 获得顶点指向光源的向量
                    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                    // 计算
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                    o.color = ambient + diffuse;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target {
                    return fixed4(i.color, 1.0);
                }
                
            ENDCG
        }
    }
    Fallback "Diffuse"
}
