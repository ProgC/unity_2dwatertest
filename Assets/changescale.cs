using UnityEngine;
using System.Collections;

public class changescale : MonoBehaviour {

	// Use this for initialization
	void Start () {
        //camera.orthographicSize = Screen.height / 2;
        camera.aspect = 960.0f / 640.0f;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
