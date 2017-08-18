#include "pso.h"

void cp_to_shared(particle *v, shared particle *p_out) {
  int i;
  for(i = 0; i < DIMENSION; i++) {
    p_out->_data[i] = v->_data[i];
    p_out->_vel[i] = v->_vel[i];
    p_out->_p_best[i] = v->_p_best[i];
  }
  p_out->_fitness = v->_fitness;
  p_out->_p_fitness = v->_p_fitness;
}

void cp_to_private(shared particle *v, particle *p_out) {
  int i;
  for(i = 0; i < DIMENSION; i++) {
    p_out->_data[i] = v->_data[i];
    p_out->_vel[i] = v->_vel[i];
    p_out->_p_best[i] = v->_p_best[i];
  }
  p_out->_fitness = v->_fitness;
  p_out->_p_fitness = v->_p_fitness;
}

void p_init(particle *v) {
}

void p_uniform(particle *v, double min, double max) {
  if(min > max) {
    printf("Error (particle_uniform): [%f, %f] is not a valid range.\n");
    exit(1);
  }
  int index;
  p_init(v);
  double range = (max - min);
  double div = RAND_MAX / range;
  for(index = 0; index < DIMENSION; index++){
    v->_data[index] = min + (rand() / div);
    v->_vel[index] = min + (rand() / div);
    v->_p_best[index] = v->_data[index];
  }
}

double p_get(particle *v, int index) {
  return v->_data[index];
}

void p_add(particle *v1, particle *v2, particle *p_out) {
  int index;
  for(index = 0; index < DIMENSION; index++) {
    p_out->_data[index] = v1->_data[index] + v2->_data[index];
  }
}
 
void p_sub(particle *v1, particle *v2, particle *p_out) {
  int index;
  for(index = 0; index < DIMENSION; index++) {
    p_out->_data[index] = v1->_data[index] - v2->_data[index];
  }
}
 
void p_mult(particle *v1, double d, particle *p_out) {
  int index;
  for(index = 0; index < DIMENSION; index++) {
    p_out->_data[index] = v1->_data[index] * d;
  }
}

void p_evaluate(particle *v) {
  double x = p_get(v, 0);
  double y = p_get(v, 1);
  v->_fitness = -0.5*pow(x, 4) + 6*pow(x-1, 3) - 3*pow(x, 2) + 2*x*y - x - pow(y-4, 4) - pow(y-2, 3) + 3*y + 1;
  //printf("Evaluating fitness:%f, (%f)\n", v->_fitness, p_get(v, 0));
}

void p_vel_update(particle *v, particle *g_best, double r_p, double r_g) {
  int index;
  for(index = 0; index < DIMENSION; index++) {
    v->_vel[index] *= OMEGA; // annealing
    v->_vel[index] += PHI_P*r_p*(v->_p_best[index] - v->_data[index]);
    v->_vel[index] += PHI_G*r_g*(g_best->_data[index] - v->_data[index]);
    v->_data[index] += v->_vel[index];
  }
  // check if new best
  p_evaluate(v);
  if(v->_fitness > v->_p_fitness) {
    for(index = 0; index < DIMENSION; index++) {
      v->_p_best[index] = v->_data[index];
    } 
    v->_p_fitness = v->_fitness;
  }
}
