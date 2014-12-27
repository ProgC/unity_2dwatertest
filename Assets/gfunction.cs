using UnityEngine;
using System.Collections;

public class gfunction : MonoBehaviour {

	// Use this for initialization
	void Start () 
    {
        for (float z = 0; z < 50; z += 0.01f)
        {
            GameObject obj = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            obj.transform.position = new Vector3(z, g(z), 0);
        }
	}

    float g(float z)
    {
        float n = 10;
        float f = 50;

        return (f/(f-n)) - ((n*f) / ((f-n) * z));
    }

    // Update is called once per frame
    void Update() 
    {
	    
	}
}
