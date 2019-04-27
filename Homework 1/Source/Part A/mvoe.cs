using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class mvoe : MonoBehaviour
{
	// Update is called once per frame
	void Update()
	{
		transform.Translate(new Vector3(Mathf.Cos(Time.time / 2f) / 6, 0, 0));
	}
}
