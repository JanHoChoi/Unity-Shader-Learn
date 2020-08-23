Shader "Custom/MyShader1"
{
    // 属性,以供Shader访问,也可以在Cg代码片中定义变量,也可以通过脚本传递这些属性.
    // Properties 语义块仅为了让这些属性可以出现在材质面板中
    Properties
    {
        _MainTex ("Texture", 2D) = "grey" {}
        _Int ("NumberInt", Int) = 2
        _Float ("NumberFloat", Float) = 1.2
        _Range ("Range", Range(0.0, 5.0)) = 3.0

        _Color ("Color", Color) = (1,1,1,1)
        _Vector ("Vector", Vector) = (1,2,3,4)

        _2D ("2D", 2D) = "red" {}
        _Cube ("Cube", Cube) = "blue" {}
        _3D ("3D", 3D) = "green" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
