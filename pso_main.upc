#include <upc.h>
#include <unistd.h>
#include "pso.h"

shared particle shard_particles[THREADS];

int main()
{
  int i;
  particle particles[PARTICLES_PER_THREAD];
  int iteration;
  char host_system_name[256];
  gethostname(host_system_name,256);
  srand(MYTHREAD);

  // print thread liveness to console
  printf("HEARTBEAT : %d / %d\n", MYTHREAD, THREADS-1);
  
  // create particles
  for(i = 0; i < PARTICLES_PER_THREAD; i++) {
    particle v;
    p_uniform(&v, -100, 100);
    particles[i] = v;
    p_evaluate(&v);

    if(i==0 || v._fitness > shard_particles[MYTHREAD]._fitness) {
      cp_to_shared(&v, &(shard_particles[MYTHREAD]));
    }
  }

  // wait for all particle creation to finish
  upc_barrier();

  // perform iterations
  for(iteration = 0; iteration < ITERATIONS; iteration++) {
    particle g_particle;
    cp_to_private(&(shard_particles[MYTHREAD]), &g_particle);
    for(int i = 0; i < THREADS; i++){
      if(shard_particles[i]._fitness > g_particle._fitness) cp_to_private(&(shard_particles[i]), &g_particle);
    }
    for(i = 0; i < PARTICLES_PER_THREAD; i++) {
      double r_p = ((double) rand()) / RAND_MAX;
      double r_g = ((double) rand()) / RAND_MAX;
      p_vel_update(&particles[i], &g_particle, r_p, r_g);
      p_evaluate(&particles[i]);
      if(particles[i]._fitness > shard_particles[MYTHREAD]._fitness) {
        cp_to_shared(&(particles[i]), &(shard_particles[MYTHREAD]));
      }
    }
    if(MYTHREAD == THREADS-1) printf("iter %d: %f at (%f, %f)\n", iteration, g_particle._fitness, p_get(&g_particle, 0), p_get(&g_particle, 1));
    upc_barrier();
  }

  return 0; 
}

/*
int main ()
{
  char host_system_name[256];
  gethostname(host_system_name,256);
  
//for each particle i = 1, ..., S do
   Initialize the particle's position with a uniformly distributed random particle: xi ~ U(blo, bup)
   Initialize the particle's best known position to its initial position: pi ← xi
   if f(pi) < f(g) then
       update the swarm's best known  position: g ← pi
   Initialize the particle's velocity: vi ~ U(-|bup-blo|, |bup-blo|)
while a termination criterion is not met do:
   for each particle i = 1, ..., S do
      for each dimension d = 1, ..., n do
         Pick random numbers: rp, rg ~ U(0,1)
         Update the particle's velocity: vi,d ← ω vi,d + φp rp (pi,d-xi,d) + φg rg (gd-xi,d)
      Update the particle's position: xi ← xi + vi
      if f(xi) < f(pi) then
         Update the particle's best known position: pi ← xi
         if f(pi) < f(g) then
            Update the swarm's best known position: g ← pi
}*/
