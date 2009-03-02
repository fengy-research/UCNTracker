
#ifndef __UCNTRACKER_CORE_PLUGIN_MANAGER_H__
#define __UCNTRACKER_CORE_PLUGIN_MANAGER_H__

#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>

G_BEGIN_DECLS


#define UCN_TYPE_PLUGIN_MODULE (ucn_plugin_module_get_type ())
#define UCN_PLUGIN_MODULE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), UCN_TYPE_PLUGIN_MODULE, UCNPluginModule))
#define UCN_PLUGIN_MODULE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), UCN_TYPE_PLUGIN_MODULE, UCNPluginModuleClass))
#define UCN_IS_PLUGIN_MODULE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), UCN_TYPE_PLUGIN_MODULE))
#define UCN_IS_PLUGIN_MODULE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), UCN_TYPE_PLUGIN_MODULE))
#define UCN_PLUGIN_MODULE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), UCN_TYPE_PLUGIN_MODULE, UCNPluginModuleClass))

typedef struct _UCNPluginModule UCNPluginModule;
typedef struct _UCNPluginModuleClass UCNPluginModuleClass;
typedef struct _UCNPluginModulePrivate UCNPluginModulePrivate;
typedef gboolean (*UCNPluginModuleModuleInitFunc) (UCNPluginModule* module);

#define UCN_TYPE_PLUGIN_MODULE_MANAGER (ucn_plugin_module_manager_get_type ())
#define UCN_PLUGIN_MODULE_MANAGER(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), UCN_TYPE_PLUGIN_MODULE_MANAGER, UCNPluginModuleManager))
#define UCN_PLUGIN_MODULE_MANAGER_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), UCN_TYPE_PLUGIN_MODULE_MANAGER, UCNPluginModuleManagerClass))
#define UCN_IS_PLUGIN_MODULE_MANAGER(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), UCN_TYPE_PLUGIN_MODULE_MANAGER))
#define UCN_IS_PLUGIN_MODULE_MANAGER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), UCN_TYPE_PLUGIN_MODULE_MANAGER))
#define UCN_PLUGIN_MODULE_MANAGER_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), UCN_TYPE_PLUGIN_MODULE_MANAGER, UCNPluginModuleManagerClass))

typedef struct _UCNPluginModuleManager UCNPluginModuleManager;
typedef struct _UCNPluginModuleManagerClass UCNPluginModuleManagerClass;
typedef struct _UCNPluginModuleManagerPrivate UCNPluginModuleManagerPrivate;
typedef struct _UCNParamSpecPluginModuleManager UCNParamSpecPluginModuleManager;

struct _UCNPluginModule {
	GTypeModule parent_instance;
	UCNPluginModulePrivate * priv;
	char* filename;
	char* init_func_name;
};

struct _UCNPluginModuleClass {
	GTypeModuleClass parent_class;
};

struct _UCNPluginModuleManager {
	GTypeInstance parent_instance;
	volatile int ref_count;
	UCNPluginModuleManagerPrivate * priv;
};

struct _UCNPluginModuleManagerClass {
	GTypeClass parent_class;
	void (*finalize) (UCNPluginModuleManager *self);
};

struct _UCNParamSpecPluginModuleManager {
	GParamSpec parent_instance;
};


UCNPluginModule* ucn_plugin_module_construct (GType object_type, const char* filename, const char* init_func);
UCNPluginModule* ucn_plugin_module_new (const char* filename, const char* init_func);
UCNPluginModule* ucn_plugin_module_construct_static (GType object_type, UCNPluginModuleModuleInitFunc init_func);
UCNPluginModule* ucn_plugin_module_new_static (UCNPluginModuleModuleInitFunc init_func);
GType ucn_plugin_module_get_type (void);
GType ucn_plugin_module_register_type (GTypeModule * module);
void ucn_plugin_module_manager_query (UCNPluginModuleManager* self, const char* filename);
void ucn_plugin_module_manager_query_static (UCNPluginModuleManager* self, UCNPluginModuleModuleInitFunc init_func);
UCNPluginModuleManager* ucn_plugin_module_manager_construct (GType object_type);
UCNPluginModuleManager* ucn_plugin_module_manager_new (void);
GParamSpec* ucn_param_spec_plugin_module_manager (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
gpointer ucn_value_get_plugin_module_manager (const GValue* value);
void ucn_value_set_plugin_module_manager (GValue* value, gpointer v_object);
GType ucn_plugin_module_manager_get_type (void);
GType ucn_plugin_module_manager_register_type (GTypeModule * module);
gpointer ucn_plugin_module_manager_ref (gpointer instance);
void ucn_plugin_module_manager_unref (gpointer instance);


G_END_DECLS

#endif
