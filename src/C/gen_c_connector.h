#ifndef GEN_C_CONNECTOR_H 
#define GEN_C_CONNECTOR_H

#define BOOST_BIND_GLOBAL_PLACEHOLDERS 0

struct MyArray {
    int m;
    int n;
    double *data;
};

typedef struct MyArray MyArray_t;



#ifdef __cplusplus
extern "C" {
#endif



  typedef double (*ofunc) (double *f, size_t d, void *p);
  
  struct GOpts {
    int algo;
    int dim;
    double* x_s;
    double* x_l;
    double* x_u;
    int iter;
    double* retRes;
    double* retErr;
    ofunc func;
  };

  typedef struct GOpts GOpts_t;

  
  int geneva_run(int argc, char** argv);
  
  int optimize (int argc, char** argv, double(*o_func)(double *f, size_t d, void* p), double* retRes, double* retErr,
		int algo, int dim, double* x_s, double* x_l, double* x_u, size_t iter);

  int g_optimize (int argc, char** argv, double(*o_func)(double *f, size_t d, void* p),  GOpts_t* opts);
  int g_optimize2 (int argc, char** argv, GOpts_t* opts);

  
  void fill_array(MyArray_t* in,
		  int m, int n, double* sourceArray);


  
#ifdef __cplusplus
}
#endif


#endif
