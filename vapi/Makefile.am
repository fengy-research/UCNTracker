EXTRA_DIST = \
gl.vapi \
glu.vapi \
glut.vapi \
glx.vapi \
gsl.vapi \
gtkglext-1.0.vapi \
valartl.vapi

valartl.vapi : ../valartl/valartl.vapi
	cat $^ > $@
BUILT_SOURCES = valartl.vapi 
EXTRA_CLEAN =  valartl.vapi
