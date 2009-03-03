SUBDIRS = builder core library tests

EXTRA_DIST = ucntracker.vapi
ucntracker.vapi: core/core.vapi builder/builder.vapi library/ucntracker.vapi 
	cat $^ > $@
