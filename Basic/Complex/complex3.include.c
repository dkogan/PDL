#include <math.h>

#ifndef M_PI
# define M_PI   3.1415926535897932384626433832795029
#endif
#ifndef M_2PI
# define M_2PI  (2. * M_PI)
#endif

#if __GLIBC__ > 1 && (defined __USE_MISC || defined __USE_XOPEN || defined __USE_ISOC9X)
# define CABS(r,i) hypot (r, i)
#else
  static double
  CABS (double r, double i)
  {
    double t;

    if (r < 0) r = - r;
    if (i < 0) i = - i;

    if (i > r)
      {
        t = r; r = i; i = t;
      }

    if (r + i == r)
      return r;

    t = i / r;
    return r * sqrt (1 + t*t);
  }
#endif

#if __GLIBC__ >= 2 && __GLIBC_MINOR__ >= 1 && defined __USE_GNU
# define SINCOS(x,s,c) sincos ((x), &(s), &(c))
#else
# define SINCOS(x,s,c)                  \
        (s) = sin (x);                  \
        (c) = cos (x);
#endif


#define CSQRT(type,ar,ai,cr,ci) 		\
        type mag = CABS ((ar), (ai));		\
        type t;					\
                                                \
        if (mag == 0)				\
          (cr) = (ci) = 0;			\
        else if ((ar) > 0)			\
          {					\
            t = sqrt (0.5 * (mag + (ar)));	\
            (cr) = t;				\
            (ci) = 0.5 * (ai) / t;		\
          }					\
        else					\
          {					\
            t = sqrt (0.5 * (mag - (ar)));	\
                                                \
            if ((ai) < 0)			\
              t = -t;				\
                                                \
            (cr) = 0.5 * (ai) / t;		\
            (ci) = t;				\
          }


#define CLOG(ar,ai,cr,ci)			\
        (cr) = log (CABS ((ar), (ai)));		\
        (ci) = atan2 ((ai), (ar));
