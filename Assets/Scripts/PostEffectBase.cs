﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{
    protected Material CreateMaterial(Shader shader, Material material)
    {
        if(shader == null)
            return null;
        if(material && material.shader == shader)
            return material;
        material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;
        Debug.Log(material.name);
        return material;
    }
}
