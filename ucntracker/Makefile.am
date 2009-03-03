SUBDIRS = builder core library tests

ucntracker.vapi: core/core.vapi builder/builder.vapi library/ucntracker.vapi 
	cat $^ > $@

