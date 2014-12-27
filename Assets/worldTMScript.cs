using UnityEngine;
using System.Collections;

public class worldTMScript : MonoBehaviour {

	// Use this for initialization
	
    void Start () {

       

        //GameObject plane = GameObject.CreatePrimitive(PrimitiveType.Plane);

        
	}
	
	// Update is called once per frame
	void Update ()
    {


        Vector3 a = new Vector3(-10.5f, 0, -10.5f);
        Vector3 b = new Vector3(10.5f, 0, 10.5f);
        
        Matrix4x4 mat = Matrix4x4.TRS(new Vector3(0f, 0f, 0f), Quaternion.EulerRotation(0, -45.0f, 0), Vector3.one);
        
        Vector3 c = mat.MultiplyVector(a);
        Vector3 d = mat.MultiplyVector(b);

        Debug.DrawLine(a, b, Color.red);

        Debug.DrawLine(c, d, Color.green);
	}
}
