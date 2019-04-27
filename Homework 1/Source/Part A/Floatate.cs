using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Floatate : MonoBehaviour
{
	void Update()
	{
		transform.position = new Vector3(transform.position.x, Mathf.Sin(Time.time), transform.position.z);
		if (transform.gameObject.name == "Capsule") transform.Rotate(0, 0, Time.deltaTime * 15);
		else transform.Rotate(0, Time.deltaTime * 15, 0);
	}
}
