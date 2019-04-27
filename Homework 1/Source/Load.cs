using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Load : MonoBehaviour
{
	public void DoLoad(int i) { SceneManager.LoadScene(i); }
}

