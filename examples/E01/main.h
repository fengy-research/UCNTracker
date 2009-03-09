
#ifndef __MAIN_H__
#define __MAIN_H__

#include <glib.h>
#include <glib-object.h>
#include <builder/gtkbuilder.h>
#include <float.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

G_BEGIN_DECLS



extern UCNBuilder* builder;
extern double MFP;
extern gint N_TRACKS;
gint _main (char** args, int args_length1);


G_END_DECLS

#endif
