// Standard header files go here
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <thread>
#include <mutex>

#include <gen_c_connector.h>

// The new geneva optimizer interface #3
#include <geneva-interface/Go3.hpp>


// The lambda to be used as evaluation function
auto lambda = [](std::vector<double>& a) {
  return std::accumulate(a.begin(), a.end(), 0.0);
};


struct gen_obj_function_struct {
  double (*f)(double * x_array, size_t dim, void * params);
  size_t dim;
  void * params;
};

typedef struct gen_obj_function_struct g_func;

#define F_EVAL(F,x) (*((F)->f))(x,(F)->dim,(F)->params)


std::mutex mtx;

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


  int optimize (int argc, char** argv, double(*o_func)(double *f, size_t d, void* p), double* retRes, double* retErr,
		int algo, int dim, double* x_s, double* x_l, double* x_u, size_t iter){

    using namespace GO3;
    
    // pack the function
    g_func  G = { *o_func, dim,  0};

    double val[3]={1,2,3};
      std::cout << " values obtained -> F(x)" <<  F_EVAL(&G, val) << " dim=" << dim << std::endl;
      
      auto lambda2 = [=](std::vector<double>& a) {
	double vv[dim];
	for (int i=0;i<dim;i++) vv[i]=a[i];
	return F_EVAL(&G,vv);
      };
      

    /*Set boundaries (start value, left & right)*/
    //std::vector<double> start{50, 50, 50}, left{0, 0, 0}, right{100, 100, 100};
      std::vector<double> start(dim), left(dim), right(dim);
      for (int i=0;i<dim;i++) {
	start[i]=x_s[i];
        left[i]=x_l[i];
	right[i]=x_u[i];
      }
      /*create optimizer,give CLI options */
    GenevaOptimizer3 go3{argc, argv};
    /* create ea , for easy handling*/
    Algorithm_EA ea{.Iterations = iter};
    /* change config parameters via [] */
    ea[cfg::Iterations] = iter;  // only accepts cfg's for EA for now...
    auto pop = Population{start, left, right, .func = lambda2, .Iterations = iter};
    /* change population config */
    pop[cfg::Size] = 1000;
    /* use the optimizer, add an Inplace GD */
    auto best_ptr = go3.optimize(pop, {ea, Algorithm_GD{.Iterations = iter}});
    std::cout << best_ptr << std::endl;

    // Retrieve the parameters
    std::vector<double> parVec;
    best_ptr->streamline(parVec);
    
    for (int i=0;i<dim;i++) {
      retRes[i]=parVec[i];
      retErr[i]=parVec[i];
      std::cout << " best_ptr i=" << i << " val=" << retRes[i] << std::endl;      
    }

    return 0;
   
  }

  int g_optimize (int argc, char** argv, double(*o_func)(double *f, size_t d, void* p), GOpts_t* opts){
       
    using namespace GO3;

    std::cout << "opts" << opts << " dim:" << opts->dim << std::endl;
   
    // Status    
    std::cout << " dim: " << opts->dim << " algo: " << opts->algo
              << " start_val[0]: " << opts->x_s[0]
              << " l_val[0]: " << opts->x_l[0]
	      << " u_val[0]: " << opts->x_u[0]
	      << std::endl;
    
      
    // Packed obj. function
    g_func  G = { *o_func, opts->dim,  0};

    double val[3]={1,2,3};
    std::cout << " Function values obtained -> F(x)" <<  F_EVAL(&G, val) << " dim=" << opts->dim << std::endl;

    
    auto lambda2 = [=](std::vector<double>& a) {
      double vv[opts->dim];
      for (size_t i=0;i<opts->dim;i++) vv[i]=a[i];
      return F_EVAL(&G,vv);
    };
    
    //Set boundaries (start value, left & right)
    //std::vector<double> start{50, 50, 50}, left{0, 0, 0}, right{100, 100, 100};
    std::vector<double> start(opts->dim), left(opts->dim), right(opts->dim);
    for (size_t i=0;i<opts->dim;i++) {
      start[i] = opts->x_s[i];
      left[i]  = opts->x_l[i];
      right[i] = opts->x_u[i];
    }

         
    // create optimizer,give CLI options 
    GenevaOptimizer3 go3{argc, argv};
    // create ea , for easy handling
    Algorithm_EA ea{.Iterations = opts->iter};
    // change config parameters via [] 
    ea[cfg::Iterations] = opts->iter;  // only accepts cfg's for EA for now...
    auto pop = Population{start, left, right, .func = lambda2, .Iterations = opts->iter};
    // change population config 
    pop[cfg::Size] = 1000;
    // use the optimizer, add an Inplace GD 
    auto best_ptr = go3.optimize(pop, {ea, Algorithm_GD{.Iterations = opts->iter}});
    std::cout << best_ptr << std::endl;
        
    // Retrieve the parameters
    std::vector<double> parVec;
    best_ptr->streamline(parVec);
    //double min_ofunc = best_ptr->fitnessCalculation();
    for (size_t i=0;i<opts->dim;i++) {
      opts->retRes[i]=parVec[i];
      opts->retErr[i]=parVec[i];
      //std::cout << " best_ptr i=" << i << " val=" << opts->retRes[i] << " min: " << min_ofunc << std::endl;
      std::cout << " best_ptr i=" << i << " val=" << opts->retRes[i] << std::endl;      
    }
   
    return 0;
  }

  int g_optimize2 (int argc, char** argv, GOpts_t* opts){
       
    using namespace GO3;

    std::cout << "argc: " << argc << "argv: " << argv[0] << std::endl;

    std::cout << "opts" << opts << " dim:" << opts->dim << std::endl;
   
    // Status    
    std::cout << " dim: " << opts->dim << " algo: " << opts->algo
              << " start_val[0]: " << opts->x_s[0]
              << " l_val[0]: " << opts->x_l[0]
	      << " u_val[0]: " << opts->x_u[0]
	      << std::endl;
    
      
    // Packed obj. function
    g_func  G = { opts->func, opts->dim,  0};

    double val[3]={1,2,3};
    std::cout << " Function values obtained -> F(x)" <<  F_EVAL(&G, val) << " dim=" << opts->dim << std::endl;

    
    auto lambda2 = [=](std::vector<double>& a) {
      double vv[opts->dim];
      for (size_t i=0;i<opts->dim;i++) vv[i]=a[i];
      return F_EVAL(&G,vv);
    };

    std::vector<double> vect{ 10, 20, 30 };
    std::cout << " Function values obtained -> lambda2(x)" <<  lambda2(vect) << std::endl;
    
    //Set boundaries (start value, left & right)
    //std::vector<double> start{50, 50, 50}, left{0, 0, 0}, right{100, 100, 100};
    std::vector<double> start(opts->dim), left(opts->dim), right(opts->dim);
    for (size_t i=0;i<opts->dim;i++) {
      start[i] = opts->x_s[i];
      left[i]  = opts->x_l[i];
      right[i] = opts->x_u[i];
    }
    // create optimizer,give CLI options 
    GenevaOptimizer3 go3{argc, argv};
    // create ea , for easy handling
    Algorithm_EA ea{.Iterations = opts->iter};
    // change config parameters via [] 
    ea[cfg::Iterations] = opts->iter;  // only accepts cfg's for EA for now...
    auto pop = Population{start, left, right, .func = lambda2, .Iterations = opts->iter};
    // change population config 
    pop[cfg::Size] = 1000;
    // use the optimizer, add an Inplace GD 
    auto best_ptr = go3.optimize(pop, {ea, Algorithm_GD{.Iterations = opts->iter}});
    std::cout << best_ptr << std::endl;
    
    // Retrieve the parameters
    std::vector<double> parVec;
    best_ptr->streamline(parVec);
    //double min_ofunc = best_ptr->fitnessCalculation();
    for (size_t i=0;i<opts->dim;i++) {
      opts->retRes[i]=parVec[i];
      opts->retErr[i]=parVec[i];
      //std::cout << " best_ptr i=" << i << " val=" << opts->retRes[i] << " min: " << min_ofunc << std::endl;
      std::cout << " best_ptr i=" << i << " val=" << opts->retRes[i] << std::endl;      
    }
   
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
