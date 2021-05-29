// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Grass" {
    Properties {
        _MainTex ("Grass Texture", 2D) = "white" {}
        _TimeScale ("Time Scale", float) = 1
    }

    SubShader{
        Tags{"Queue"="Transparent" "RenderType"="Opaque" "IgnoreProject"="True"}
        Pass{
            Tags{"LightMode"="ForwardBase"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc" 

            sampler2D _MainTex;
            half _TimeScale;

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };


            v2f vert(a2v v){
                v2f o;
                float4 offset = float4(0,0,0,0);
                float3 worldPos = UnityObjectToViewPos(v.vertex);

                //从多高开始抖动
                float jitterFromY = (sin(worldPos.x * 0.5 + worldPos.y * 0.4) + 1) * 0.5 * 0.4;
                jitterFromY = clamp(v.texcoord.y - jitterFromY, 0, 1);
                //随worldPos.x, worldPos.y随机抖动幅度
                offset.x = 0.01 * sin(3 * _Time.y + worldPos.x * 0.5 + worldPos.y * 0.4) * jitterFromY;

                //草尖抖动加倍
                float jitterPower = (1.2 + clamp(v.texcoord.y - 0.7, 0, 1));
                offset.x = offset.x * jitterPower * jitterPower * jitterPower;

                //offset.x = 0.02 * sin(2 * _Time.y) * clamp(v.texcoord.y - 0.0, 0, 1);

                o.pos = UnityObjectToClipPos(v.vertex) + offset;
                o.uv = v.texcoord.xy;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return tex2D(_MainTex, i.uv);
            }

            ENDCG
        }
    }
    FallBack Off
}