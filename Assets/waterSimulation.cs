using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class waterSimulation : MonoBehaviour 
{
    List<GameObject> mParticles = new List<GameObject>();

	// Use this for initialization
	void Start () 
    {
        for ( int i = 0; i < 100; ++i )
        {
            GameObject obj = (GameObject)Instantiate(Resources.Load("ball") as GameObject, new Vector3(i * 1 * 0.001f, 0, 0), Quaternion.identity);
            mParticles.Add(obj);
        }
	}

    void FixedUpdate()
    {
        // 높이값에 따라 낮으면 낮을 수록 radius를 크게 한다.
        for (int i = 0; i < mParticles.Count; ++i)
        {
            GameObject obj = mParticles[i];
                        
            Vector3 pos = obj.GetComponentInChildren<Rigidbody>().transform.position;
            float y = (pos.y + 4) / 8.0f;

            ballScript ballScript = obj.GetComponent<ballScript>();
            

            // height 8
            SphereCollider sphereCollider = obj.GetComponentInChildren<SphereCollider>();
            if (sphereCollider != null)
            {
                sphereCollider.radius = Mathf.Lerp(0.23f, 0.001f, y);
            }

            
            float size = Mathf.Lerp(2, 0.3f, y);
            ballScript.mSphere.transform.localScale = new Vector3(size, size, size);
        }
    }
}
