
#ifndef __TEST_GTK_H__
#define __TEST_GTK_H__

#include <glib.h>
#include <glib-object.h>
#include <valartl/builder.h>
#include <camera.h>
#include <stdlib.h>
#include <string.h>

G_BEGIN_DECLS



extern ValaRuntimeBuilder* builder;
extern UCNCamera* gl;
gint _main (char** args, int args_length1);
#define GML "\n---\n- &experiment\n  class : UCNExperiment\n  children :\n  - *environment\n  - *part1\n  - class : UCNGravityField\n    g : 0.1\n    children:\n    - *env\n- &environment\n  class : UCNPart\n  layer : -1\n  children:\n  - *env\n- &part1\n  class : UCNPart\n  layer : 0\n  children:\n  - class : UCNBall\n    radius : 2\n    center : 1, 2, 3\n- &env\n  class : UCNBall\n  center : 0, 0, 0\n  radius : 100\n...\n"


G_END_DECLS

#endif
