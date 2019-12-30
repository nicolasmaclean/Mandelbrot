﻿using UnityEngine;

public class Controller : MonoBehaviour
{
    public Material material;
    public Vector2 pos;
    public float scale, angle, smoothLerp, red, green, blue, alpha;
    public int maxIter;

    private Vector2 smoothPos;
    private float smoothScale, smoothAngle;

    private void handleInput()
    {
        if(Input.GetKey(KeyCode.UpArrow))
            scale *= .99f;
        else if(Input.GetKey(KeyCode.DownArrow))
            scale *= 1.01f;

        if(Input.GetKey(KeyCode.E))
            angle += .03f; 
        else if(Input.GetKey(KeyCode.Q))
            angle -= .03f; 

        Vector2 dir = new Vector2(0.1f * scale, 0);
        float c = Mathf.Cos(angle);
        float s = Mathf.Sin(angle);
        dir = new Vector2(dir.x*c, dir.x*s);

        if(Input.GetKey(KeyCode.D))
            pos += dir;
        else if(Input.GetKey(KeyCode.A))
            pos -= dir;

        dir = new Vector2(-dir.y, dir.x);

        if(Input.GetKey(KeyCode.W))
            pos += dir;
        else if(Input.GetKey(KeyCode.S))
            pos -= dir;
    }
    private void updateShader()
    {
        smoothPos = Vector2.Lerp(smoothPos, pos, smoothLerp);
        smoothScale = Mathf.Lerp(smoothScale, scale, smoothLerp);
        smoothAngle = Mathf.Lerp(smoothAngle, angle, smoothLerp);

        float aspect = (float)Screen.width / (float)Screen.height;

        float scaleX = smoothScale;
        float scaleY = smoothScale;

        if(aspect > 1)
            scaleY /= aspect;
        else
            scaleX *= aspect;

        material.SetVector("_Area", new Vector4(smoothPos.x, smoothPos.y, scaleX, scaleY));
        material.SetVector("_Color", new Vector4(red, green, blue, alpha));
        material.SetInt("_MaxIter", maxIter);
    }
    
    void FixedUpdate()
    {
        handleInput();
        updateShader();
    }
}
