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
 
  int geneva_run(int argc, char** argv);
  int optimize(double(*f)(const double* a, const int n));
  void fill_array(MyArray_t* in,
		  int m, int n, double* sourceArray);


  
#ifdef __cplusplus
}
#endif


#endif
