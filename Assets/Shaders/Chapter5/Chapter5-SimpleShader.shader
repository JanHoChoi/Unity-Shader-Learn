Shader "Unity Shaders Book/Chapter 5/Simple Shader"{

	Properties{
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader{
		Pass{
			CGPROGRAM

			#pragma vertex vert     // vert函数名 表示该函数包含顶点着色器代码

			#pragma fragment frag   // frag函数名

			fixed4 _Color;

           	// application to vertex
           	struct a2v{
           		float4 vertex : POSITION;
           		float3 normal : NORMAL;
           		float4 texcoord : TEXCOORD0;
           	};

            // vertex to fragment
            struct v2f{
            	float4 pos : SV_POSITION;	// 裁剪空间坐标
            	float3 color : COLOR0;
            };

            v2f vert(a2v v){
            	v2f o;	// 声明output
            	o.pos = UnityObjectToClipPos(v.vertex);
            	o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);	// normal的三个方向分量在[-1,1],把其映射到[0,1]中
            	return o;
            }

            fixed4 frag(v2f i) : SV_Target{
            	fixed3 c = i.color;
            	c *= _Color.rgb;
            	return fixed4(c, 1.0);
            }

            ENDCG
        }
    }
}