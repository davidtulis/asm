// Example C++ program that calls an Assembly procedure
// CPEN 3710 lab 11
// Joe Dumas, David Tulis
//Due 11/25/14

// This program calls an assembly program named quadform
// with the 3 coefficients A, B, C of a quadratic equation
// Ax^2 + Bx + C.  The assembly program computes the value
// under the radical in the quadratic formula, specifically
// B^2 - 4AC, returning the value in EAX as expected by the
// Visual C++ compiler

#include <iostream>
#include <fstream>
using namespace std;


extern "C" {int quadform(float a, float b, float c, float* root1Ptr, float* root2Ptr);}

int main()
{
	
	float mya, myb, myc;			// coefficients
	float answer1;
	float answer2;			// result

	cout << "Please enter the coefficients of the quadratic formula\n";
	cout << "such that Ax^2 + Bx + C = 0 \n";
	
	getA:
	cout << "A = ";				// get inputs a,b and c
	cin >> mya;

	//if a=0, we will be dividing by zero (which is not good)
	if (mya==0)
	{
		cout << "A cannot be zero! Try again!\n";
		//please don't shoot me
		goto getA;	
	}
	
	
	cout << "B = ";
	cin >> myb;

	cout << "C = ";
	cin >> myc;
	
	// compute equation in assembly
	int results = quadform (mya, myb, myc, &answer1, &answer2);	
	
	//returns -1 if the results are imaginary (happens when the determinate is <0)
	if (results==-1) 
	{
		cout << "The roots are complex\n";
	}
	else
	{
		cout << answer1;
		cout << "\n";
		cout << answer2;
		cout << "\n";
	}

	cin >> myb;

	return (0);
}
