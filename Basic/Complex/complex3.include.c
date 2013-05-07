#include <tgmath.h>

#if __GLIBC__ >= 2 && __GLIBC_MINOR__ >= 1 && defined __USE_GNU
# define SINCOS(x,s,c) sincos ((x), &(s), &(c))
#else
# define SINCOS(x,s,c)                  \
        (s) = sin (x);                  \
        (c) = cos (x);
#endif
