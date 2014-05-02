#ifndef __cc2420_H_
#define __cc2420_H_

#if !defined(CC2420X) || defined(PLATFORM_Z1) || defined(TOSSIM)
typedef TMicro TRadio;
typedef uint16_t tradio_size;
#else
#include <RadioConfig.h>
#endif

#endif
