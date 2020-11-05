using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase
{
    public Shader motionBlurShader;
    private Material motionBlurMat;
    public Material material
    {
        get
        {
            motionBlurMat = CreateMaterial(motionBlurShader, motionBlurMat);
            return motionBlurMat;
        }
    }

    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;     // 值越大,拖尾效果越明显

    private RenderTexture accumulationTexture;  // 累加效果的rendertexture

    private void OnDisable()
    {
        DestroyImmediate(accumulationTexture);   // 脚本关闭时,销毁该RT,避免对重新叠加模糊时造成影响
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            if(accumulationTexture == null || accumulationTexture.width != source.width || accumulationTexture.height != source.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(source.width, source.height, 0);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
            }

            accumulationTexture.MarkRestoreExpected();  // 如果一个RT没有销毁或者清除就渲染,Unity会报警告,用这个语句关掉它

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            Graphics.Blit(source, accumulationTexture, material);
            Graphics.Blit(accumulationTexture, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
