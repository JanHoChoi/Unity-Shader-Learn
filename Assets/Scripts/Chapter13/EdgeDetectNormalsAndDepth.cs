using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalsAndDepth : PostEffectBase
{
    public Shader edgeDetectShader;

    private Material edgeDetectMaterial = null;

    public Material material
    {
        get
        {
            edgeDetectMaterial = CreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    [Range(0f, 1f)]
    public float edgesOnly = 0.0f;      // edgesOnly=0 边缘叠加在原图像上, =1 只显示边缘

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f; // 值越大,描边越宽

    public float sensitivityDepth = 1.0f;  // sensitivity影响灵敏度,如果设很大,即使深度/法线变化很小也会被觉得有边

    public float sensitivityNormals = 1.0f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
