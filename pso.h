#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef PSO_HEADER
#define PSO_HEADER
#define PARTICLES_PER_THREAD 40
#define DIMENSION 2
#define ITERATIONS 40
#define OMEGA 0.7
#define PHI_P 0.1
#define PHI_G 0.15

typedef struct {
  double _data[DIMENSION]; 
  double _vel[DIMENSION];
  double _p_best[DIMENSION];
  double _fitness;
  double _p_fitness;
} particle;
void cp_to_shared(particle *v, shared particle *p_out);
void cp_to_private(shared particle *v, particle *p_out);
void p_init(particle *v);
void p_uniform(particle *v, double min, double max);
double p_get(particle *v, int index);
void p_add(particle *v1, particle *v2, particle *p_out);
void p_sub(particle *v, particle *v2, particle *p_out);
void p_mult(particle *v, double d, particle *p_out);
void p_vel_update(particle *v, particle *g_best, double r_p, double r_g);
void p_evaluate(particle *v);
#endif

