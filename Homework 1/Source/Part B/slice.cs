using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class slice : MonoBehaviour
{
	int step = 10;
	Vector2 count = new Vector2();
	// Start is called before the first frame update
	void Start()
	{
	}

	// Update is called once per frame
	void Update()
	{
		count += new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));

		Material mat = GetComponent<MeshRenderer>().material;

		if (Mathf.Floor(count.x) % step == 0 || Mathf.Floor(count.y) % step == 0)
		{
			mat.SetFloat("_X", Mathf.Floor(-count.x));
			mat.SetFloat("_Y", Mathf.Floor(-count.y));
		}

	}
}
