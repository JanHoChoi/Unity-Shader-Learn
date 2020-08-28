using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;

    #region Material properties
    [SerializeField]
    private int m_textureWidth = 512;

    public int textureWidth {
        get {
            return m_textureWidth;
        }
        set {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField]
    private Color m_backgroundColor = Color.white;
    
    public Color BackgroundColor{
        get{
            return m_backgroundColor;
        }
        set{
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField]
    private Color m_circleColor = Color.yellow;
    
    public Color CircleColor{
        get{
            return m_circleColor;
        }
        set{
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField]
    private float m_blurFactor = 2.0f;
    
    public float BlurFactor{
        get{
            return m_blurFactor;
        }
        set{
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }
    #endregion

    private Texture2D m_generatedTexture = null;

    void Start(){
        if(material == null){
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer == null){
                Debug.Log("Cannot Find a renderer.");
                return;
            }
            material = renderer.sharedMaterial;
        }
        _UpdateMaterial();
    }

    public void _UpdateMaterial(){
        if(material != null){
            m_generatedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    private Texture2D _GenerateProceduralTexture(){
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

        float circleInterval = textureWidth / 4.0f;
        float radius = textureWidth / 10.0f;

        float edgeBlur = 1.0f/BlurFactor;

        for(int w = 0; w < textureWidth; w++){
            for(int h = 0; h < textureWidth; h++){
                Color pixel = BackgroundColor;

                for(int i = 0; i < 3; i++){
                    for(int j = 0; j < 3; j++){
                        // 计算圆心位置
                        Vector2 circleCenter = new Vector2(circleInterval * (i+1), circleInterval * (j+1));

                        // 计算当前像素与圆心距离;
                        float dist = Vector2.Distance(new Vector2(w,h), circleCenter) - radius;
                        
                        // 模糊边界
                        Color color = _MixColor(CircleColor, new Color(pixel.r, pixel.g, pixel.b, 0.1f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));
                        
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        proceduralTexture.Apply();
        return proceduralTexture;
    }

    Color _MixColor(Color color0, Color color1, float mixFactor){
        Color mixColor = Color.white;
		mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
		mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
		mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
		mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
		return mixColor;
    }
}
