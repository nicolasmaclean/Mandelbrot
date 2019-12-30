Shader "Explorer/Mandelbrot"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Area ("Area", vector) = (0, 0, 4, 4)
        _Color ("Color", vector) = (.3, .45, .65, 1)
        _Angle ("Angle", range(-3.1415, 3.1415)) = 0
        _MaxIter ("Max Iterations", range(4, 1000)) = 255
        _Gradient ("Gradient", range(0, 1)) = .35
        _Repeat("Repeat", float) = 1
        _Speed("Speed", float) = 1
        _Mode("Color Mode", range(0, 2)) = 1
        _SmoothBool("Smooth Iteration", range(0, 1)) = 0
        _LeavesBool("Leaves", range(0, 1)) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 _Area, _Color;
            float _Angle, _MaxIter, _Gradient, _Repeat, _Speed, _Mode, _SmoothBool, _LeavesBool;
            sampler2D _MainTex;

            float2 rotate(float2 p, float2 pivot, float a) {
                float s = sin(a);
                float c = cos(a);

                p -= pivot;
                p = float2(p.x*c - p.y*s, p.x*s + p.y*c);
                p += pivot;

                return p;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 c = _Area.xy + (i.uv-.5)*_Area.zw;
                c = rotate(c, _Area.xy, _Angle);
                float2 z;
                float2 zPrev;
                float iter;
                float r = 20;
                float r2 = r * r;

                for(iter = 0; iter < _MaxIter; iter++) {
                    zPrev = z;
                    z = float2(z.x*z.x - z.y*z.y, 2*z.x*z.y) + c; // the first component of the float2 is the real part and the second is the imaginary part
                    if(length(z) > r && _LeavesBool != 1) break;
                    else if(dot(z, zPrev) > r) break;
                }

                if(iter >= _MaxIter) return 0; // the inside of the fractal will be black

                float fracIter;
                if(_SmoothBool == 1 || _LeavesBool) {
                    float dist = length(z); // smooth iteration
                    // fracIter = (dist - r) / (r2 - r); // linear interpolation
                    fracIter = log2( log(dist) / log(r)); // exponential interpolation
                    if(_SmoothBool == 1)
                        iter -= fracIter;
                }


                float m = sqrt(iter/_MaxIter);
                float4 color;

                switch(_Mode) {
                    default : color = float4(m, m, m, 1); break;
                    case 0 : color = float4(m, m, m, 1); break; // grayscale
                    case 1 : color = sin(_Color * m*20 + _Time.y*_Speed)*.5 + .5; break; // procedural
                    case 2 : color = tex2D(_MainTex, float2(m * _Repeat + _Time.y*_Speed, _Gradient)); break; // uses the gradient png to pick the color of each pixel
                }

                if(_LeavesBool == 1)
                    color *= smoothstep(3, 0, fracIter); // shadows on the leaves

                return color;
            }
            ENDCG
        }
    }
}
