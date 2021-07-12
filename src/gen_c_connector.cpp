// Standard header files go here
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <gen_c_connector.h>

// The new geneva optimizer interface #3
#include <geneva-interface/Go3.hpp>



// The lambda to be used as evaluation function
auto lambda = [](std::vector<double>& a) {
  return std::accumulate(a.begin(), a.end(), 0.0);
};


#ifdef __cplusplus
extern "C" {
#endif

  
  int geneva_run(int argc, char** argv){
    using namespace GO3;
    /*Set boundaries (start value, left & right)*/
    std::vector<double> start{50, 50, 50}, left{0, 0, 0}, right{100, 100, 100};
    /*create optimizer,give CLI options */
    GenevaOptimizer3 go3{argc, argv};
    /* create ea , for easy handling*/
    Algorithm_EA ea{.Iterations = 30};
    /* change config parameters via [] */
    ea[cfg::Iterations] = 100;  // only accepts cfg's for EA for now...
    auto pop = Population{start, left, right, .func = lambda, .Iterations = {10}};
    /* change population config */
    pop[cfg::Size] = 1000;
    /* use the optimizer, add an Inplace GD */
    auto best_ptr = go3.optimize(pop, {ea, Algorithm_GD{.Iterations = 1005}});
    std::cout << best_ptr << std::endl;
    return 0;
  }


  int optimize(double(*f)(const double* a, const int n)){
    double arr[3];
    for(int i=0;i<3;i++)  arr[i]=i*10.;
    std::cout<<"optimze res: " << f(arr,3) << std::endl;
    return 0;
  }


  void fill_array(MyArray_t* in,
		  int m, int n, double* sourceArray)
  {
    // int i, j;
    
    printf("\n\n_______________________________________\n");
    // Print out the address of struct pointer 'in', 'in->data' 
    printf("C addresses...\n");
    printf("MyArray       : %p   |   Array in MyArray: %p   |   Size of MyArray 'in' in C: %lu\n", in, in->data, sizeof(*in));
    printf("Source array  : %p\n\n", sourceArray);
    
    // Allocate space in for the array
    //printf("Allocating memory...\n\n");
    //in->data = (double* ) malloc(m * n * sizeof(double));
    
    // Let the array pointer in struct 'in' passed by Julia point to the array
    // 'sourceArray'
    printf("Filling array...\n\n");
    in->m = m;
    in->n = n;
    in->data = sourceArray;
    
    // Print out the address of struct pointer 'in', 'in->data' after
    // changing array pointer
    printf("New C addresses...\n");
    printf("MyArray       : %p   |   Array in MyArray: %p   |   Size of MyArray 'in' in C: %lu\n", in, in->data, sizeof(*in));
    printf("Source array  : %p", sourceArray);
    printf("\n_______________________________________\n");
    
  }
  
  

  
  
#ifdef __cplusplus
}
#endif  
