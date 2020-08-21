Shader "Custom/CartoonSmoke"
{
    Properties
    {
        _BGColor("Diffuse BG", Color) = (1, 1, 1, 1)
        _SPColor("Diffuse Spec", Color) = (1, 1, 1, 1)
        _SPstep("SP step", float) = 0.7
        _ShadowStep("Shadow step", float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

			float4 _BGColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_APPLY_FOG(i.fogCoord, col);
                return _BGColor;
            }
            ENDCG
        }
		
		Pass
		{
			Tags { "LightMode"="ForwardBase"} 
			CGPROGRAM

			#pragma vertex vertShadow
            #pragma fragment fragShadow
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
            #include "AutoLight.cginc" 
			
			float4 _LightColor0; 
			float _SPstep;
            float _ShadowStep;

			struct v2f
            {
                float4 pos : SV_POSITION;
                float3 lightDir : TEXCOORD0;
                float3 normal : TEXCOORD1;
				LIGHTING_COORDS(2, 3) 
            };
			
			v2f vertShadow(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

		        
                o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
                o.normal = normalize(v.normal).xyz;

				TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }
			float4 _BGColor;
			float4 _SPColor;
            float4 fragShadow(v2f i) : COLOR
            { 
                float3 L = normalize(i.lightDir);
                float3 N = normalize(i.normal);
                float NdotL = saturate(dot(N, L));
				
				float sp = step(_SPstep, NdotL);
				fixed3 c = _BGColor.xyz + _SPColor * sp;
                float4 diffuseTerm = _LightColor0 * LIGHT_ATTENUATION(i); 
                float shadow = step(_ShadowStep, diffuseTerm.x);
                return fixed4(c* shadow, 1);
            }

            ENDCG
		}

    }
	FallBack "Diffuse"
}
