using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
{
    public Shader bloomShader;

    private Material bloomMat;
    public Material material
    {
        get
        {
            bloomMat = CreateMaterial(bloomShader, bloomMat);
            return bloomMat;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;      // 高斯模糊迭代次数
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f; // 高斯模糊范围 值越大,模糊程度越高,但可能虚影
    [Range(1, 8)]
    public int downSample = 2;      // 缩放系数     值越大,需要处理的像素越少,也能提高模糊程度,但可能像素化
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f; // bloom的亮度阈值

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;   // 降采样

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0); // 因为两个pass,所以分配一块大小相同的缓冲区
            buffer0.filterMode = FilterMode.Bilinear; // Bilinear使图像变形时会变模糊

            Graphics.Blit(source, buffer0, material, 0);     // source缩放后放到buffer0中,同时在pass0提取亮的区域

            for (int i = 0; i < iterations; ++i) // 模糊多次
            {
                material.SetFloat("_BlurSize", 1f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 1);   // vertical pass

                RenderTexture.ReleaseTemporary(buffer0);

                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 2);   // hoirizontal pass

                RenderTexture.ReleaseTemporary(buffer0);

                buffer0 = buffer1;
            }

            material.SetTexture("_Bloom", buffer0);     // bloom纹理
            Graphics.Blit(source, destination, material, 3);
            RenderTexture.ReleaseTemporary(buffer0); // 释放内存
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
