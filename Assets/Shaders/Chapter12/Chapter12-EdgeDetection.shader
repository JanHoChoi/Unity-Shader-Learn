Shader "Unity Shaders Book/Chapter 12/Edge Detection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 1.0
        _EdgeColor ("Edge Color", Color) = (0,0,0,1)
        _BackgroundColor ("Background Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;   // 纹素大小, _MainTex纹理对应的每个纹素大小
            float _EdgeOnly;
            fixed4 _EdgeColor, _BackgroundColor;

            struct a2v {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv[9] : TEXCOORD0;
            };

            fixed luminance(fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;  // 算出灰度值
            }

            half Sobel(v2f i)
            {
                /* 原sobel算子 
                    X  = -1 0 +1  Y  = -1 -2 -1
                         -2 0 +2        0  0  0
                         -1 0 +1       +1 +2 +1

                    X  * 6 7 8 = Gx先进行核翻转(可以理解成先翻转行,再翻转列),即从 a b c    g h i    i h g
                         3 4 5                                              d e f => d e f => f e d
                         0 1 2                                              g h i    a b c    c b a， 再让i与左上角,h与正上交逐个相乘再相加
                                                                                                            (不要理解成矩阵)

                */
                const half Gx[9] = { -1, 0, 1,
                                    -2, 0, 2,
                                    -1, 0, 1};
                const half Gy[9] = { -1, -2, -1,
                                    0, 0, 0,
                                    1, 2, 1};   // 这里的Gx和Gy都是未翻转的,但是就算翻转了,uv[i]与Gx[i]也需要对准,所以没必要翻了

                /*
                翻转后的就是Gx            Gy
                            +1 0 -1         +1 +2 +1
                            +2 0 -2          0  0  0
                            +1 0 -1         -1 -2 -1
                解释见:https://github.com/candycat1992/Unity_Shaders_Book/issues/24
                */

                half texColor;
                half edgeX = 0;
                half edgeY = 0;
                for(int it = 0; it < 9; it++) {
                    texColor = luminance(tex2D(_MainTex, i.uv[it]));    // 灰度值
                    edgeX += texColor * Gx[it];     // edgeX绝对值越大,表示该点水平梯度越大,得到垂直方向边缘线
                    edgeY += texColor * Gy[it];     // edgeY绝对值越大,表示该点垂直梯度越大,得到水平方向边缘线

                    /*
                        uv数组采样为:
                            6 7 8
                            3 4 5
                            0 1 2
                        积核的正负值应该与采样坐标变化方向相同，也就是说，应该是采样坐标(uv大)越大的像素去减去采样坐标较小的像素，算差值
                        比如算Gx时,uv[2]/uv[5]/uv[8]在u坐标上比uv[0]/uv[3]/uv[6]大,所以应该uv[0]/uv[3]/uv[6]与Gx[0]/Gx[3]/Gx[6](-1,-2,-1)相乘再相加
                        而算Gy时,uv[6]/uv[7]/uv[8]在v坐标上比uv[0]/uv[1]/uv[2]大,所以依然是uv[6]/uv[7]/uv[8]与Gy[6]/Gy[7]/Gy[8]相乘再相加
                    */
                }

                half edge = 1 - abs(edgeX) - abs(edgeY);    // 因为边缘点为黑色,所以1-绝对值 edge越小,越是边缘点
                return edge;
            }

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);  
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1); 
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
                /*
                    6 7 8
                    3 4 5
                    0 1 2
                */
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half edge = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }

            ENDCG
        }
    }
    Fallback Off
}
