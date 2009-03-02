
#include <ucntracker/core/plugin-manager.h>
#include <gmodule.h>
#include <gobject/gvaluecollector.h>

typedef void (*UCNPluginModuleModuleUninitFunc) (UCNPluginModule* module);



struct _UCNPluginModulePrivate {
	GModule* library;
	UCNPluginModuleModuleInitFunc init;
	UCNPluginModuleModuleUninitFunc uninit;
};

#define UCN_PLUGIN_MODULE_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), UCN_TYPE_PLUGIN_MODULE, UCNPluginModulePrivate))
enum  {
	UCN_PLUGIN_MODULE_DUMMY_PROPERTY
};
static gboolean ucn_plugin_module_real_load (GTypeModule* base);
static void ucn_plugin_module_real_unload (GTypeModule* base);
static gpointer ucn_plugin_module_parent_class = NULL;
static void ucn_plugin_module_finalize (GObject* obj);
struct _UCNPluginModuleManagerPrivate {
	GList* modules;
};

#define UCN_PLUGIN_MODULE_MANAGER_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), UCN_TYPE_PLUGIN_MODULE_MANAGER, UCNPluginModuleManagerPrivate))
enum  {
	UCN_PLUGIN_MODULE_MANAGER_DUMMY_PROPERTY
};
static void _g_list_free_g_object_unref (GList* self);
static gpointer ucn_plugin_module_manager_parent_class = NULL;
static void ucn_plugin_module_manager_finalize (UCNPluginModuleManager* obj);



UCNPluginModule* ucn_plugin_module_construct (GType object_type, const char* filename, const char* init_func) {
	UCNPluginModule * self;
	char* _tmp1;
	const char* _tmp0;
	char* _tmp3;
	const char* _tmp2;
	GModule* _tmp4;
	void* pointer;
	g_return_val_if_fail (filename != NULL, NULL);
	g_return_val_if_fail (init_func != NULL, NULL);
	self = g_object_newv (object_type, 0, NULL);
	_tmp1 = NULL;
	_tmp0 = NULL;
	self->filename = (_tmp1 = (_tmp0 = filename, (_tmp0 == NULL) ? NULL : g_strdup (_tmp0)), self->filename = (g_free (self->filename), NULL), _tmp1);
	_tmp3 = NULL;
	_tmp2 = NULL;
	self->init_func_name = (_tmp3 = (_tmp2 = self->init_func_name, (_tmp2 == NULL) ? NULL : g_strdup (_tmp2)), self->init_func_name = (g_free (self->init_func_name), NULL), _tmp3);
	_tmp4 = NULL;
	self->priv->library = (_tmp4 = g_module_open (filename, 0), (self->priv->library == NULL) ? NULL : (self->priv->library = (g_module_close (self->priv->library), NULL)), _tmp4);
	pointer = NULL;
	g_module_symbol (self->priv->library, self->init_func_name, &pointer);
	self->priv->init = (UCNPluginModuleModuleInitFunc) pointer;
	return self;
}


UCNPluginModule* ucn_plugin_module_new (const char* filename, const char* init_func) {
	return ucn_plugin_module_construct (UCN_TYPE_PLUGIN_MODULE, filename, init_func);
}


UCNPluginModule* ucn_plugin_module_construct_static (GType object_type, UCNPluginModuleModuleInitFunc init_func) {
	UCNPluginModule * self;
	char* _tmp0;
	self = g_object_newv (object_type, 0, NULL);
	_tmp0 = NULL;
	self->filename = (_tmp0 = NULL, self->filename = (g_free (self->filename), NULL), _tmp0);
	self->priv->init = init_func;
	return self;
}


UCNPluginModule* ucn_plugin_module_new_static (UCNPluginModuleModuleInitFunc init_func) {
	return ucn_plugin_module_construct_static (UCN_TYPE_PLUGIN_MODULE, init_func);
}


static gboolean ucn_plugin_module_real_load (GTypeModule* base) {
	UCNPluginModule * self;
	self = (UCNPluginModule*) base;
	if (self->priv->init != NULL) {
		self->priv->init (self);
		return TRUE;
	} else {
		return FALSE;
	}
}


static void ucn_plugin_module_real_unload (GTypeModule* base) {
	UCNPluginModule * self;
	GModule* _tmp0;
	self = (UCNPluginModule*) base;
	if (self->priv->uninit != NULL) {
		self->priv->uninit (self);
	}
	_tmp0 = NULL;
	self->priv->library = (_tmp0 = NULL, (self->priv->library == NULL) ? NULL : (self->priv->library = (g_module_close (self->priv->library), NULL)), _tmp0);
	self->priv->init = NULL;
	self->priv->uninit = NULL;
}


static void ucn_plugin_module_class_init (UCNPluginModuleClass * klass) {
	ucn_plugin_module_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (UCNPluginModulePrivate));
	G_OBJECT_CLASS (klass)->finalize = ucn_plugin_module_finalize;
	G_TYPE_MODULE_CLASS (klass)->load = ucn_plugin_module_real_load;
	G_TYPE_MODULE_CLASS (klass)->unload = ucn_plugin_module_real_unload;
}


static void ucn_plugin_module_instance_init (UCNPluginModule * self) {
	self->priv = UCN_PLUGIN_MODULE_GET_PRIVATE (self);
}


static void ucn_plugin_module_finalize (GObject* obj) {
	UCNPluginModule * self;
	self = UCN_PLUGIN_MODULE (obj);
	self->filename = (g_free (self->filename), NULL);
	self->init_func_name = (g_free (self->init_func_name), NULL);
	(self->priv->library == NULL) ? NULL : (self->priv->library = (g_module_close (self->priv->library), NULL));
	G_OBJECT_CLASS (ucn_plugin_module_parent_class)->finalize (obj);
}


static GType ucn_plugin_module_type_id = 0;
GType ucn_plugin_module_get_type (void) {
	return ucn_plugin_module_type_id;
}


GType ucn_plugin_module_register_type (GTypeModule * module) {
	static const GTypeInfo g_define_type_info = { sizeof (UCNPluginModuleClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) ucn_plugin_module_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (UCNPluginModule), 0, (GInstanceInitFunc) ucn_plugin_module_instance_init, NULL };
	ucn_plugin_module_type_id = g_type_module_register_type (module, G_TYPE_TYPE_MODULE, "UCNPluginModule", &g_define_type_info, 0);
	return ucn_plugin_module_type_id;
}


static void _g_list_free_g_object_unref (GList* self) {
	g_list_foreach (self, (GFunc) g_object_unref, NULL);
	g_list_free (self);
}


void ucn_plugin_module_manager_query (UCNPluginModuleManager* self, const char* filename) {
	UCNPluginModule* module;
	UCNPluginModule* _tmp0;
	g_return_if_fail (self != NULL);
	g_return_if_fail (filename != NULL);
	module = ucn_plugin_module_new (filename, "ucn_plugin_module_init");
	_tmp0 = NULL;
	self->priv->modules = g_list_prepend (self->priv->modules, (_tmp0 = module, (_tmp0 == NULL) ? NULL : g_object_ref (_tmp0)));
	g_type_module_use ((GTypeModule*) module);
	(module == NULL) ? NULL : (module = (g_object_unref (module), NULL));
}


void ucn_plugin_module_manager_query_static (UCNPluginModuleManager* self, UCNPluginModuleModuleInitFunc init_func) {
	UCNPluginModule* module;
	UCNPluginModule* _tmp0;
	g_return_if_fail (self != NULL);
	module = ucn_plugin_module_new_static (init_func);
	_tmp0 = NULL;
	self->priv->modules = g_list_prepend (self->priv->modules, (_tmp0 = module, (_tmp0 == NULL) ? NULL : g_object_ref (_tmp0)));
	g_type_module_use ((GTypeModule*) module);
	(module == NULL) ? NULL : (module = (g_object_unref (module), NULL));
}


UCNPluginModuleManager* ucn_plugin_module_manager_construct (GType object_type) {
	UCNPluginModuleManager* self;
	self = (UCNPluginModuleManager*) g_type_create_instance (object_type);
	return self;
}


UCNPluginModuleManager* ucn_plugin_module_manager_new (void) {
	return ucn_plugin_module_manager_construct (UCN_TYPE_PLUGIN_MODULE_MANAGER);
}


static void ucn_value_plugin_module_manager_init (GValue* value) {
	value->data[0].v_pointer = NULL;
}


static void ucn_value_plugin_module_manager_free_value (GValue* value) {
	if (value->data[0].v_pointer) {
		ucn_plugin_module_manager_unref (value->data[0].v_pointer);
	}
}


static void ucn_value_plugin_module_manager_copy_value (const GValue* src_value, GValue* dest_value) {
	if (src_value->data[0].v_pointer) {
		dest_value->data[0].v_pointer = ucn_plugin_module_manager_ref (src_value->data[0].v_pointer);
	} else {
		dest_value->data[0].v_pointer = NULL;
	}
}


static gpointer ucn_value_plugin_module_manager_peek_pointer (const GValue* value) {
	return value->data[0].v_pointer;
}


static gchar* ucn_value_plugin_module_manager_collect_value (GValue* value, guint n_collect_values, GTypeCValue* collect_values, guint collect_flags) {
	if (collect_values[0].v_pointer) {
		UCNPluginModuleManager* object;
		object = collect_values[0].v_pointer;
		if (object->parent_instance.g_class == NULL) {
			return g_strconcat ("invalid unclassed object pointer for value type `", G_VALUE_TYPE_NAME (value), "'", NULL);
		} else if (!g_value_type_compatible (G_TYPE_FROM_INSTANCE (object), G_VALUE_TYPE (value))) {
			return g_strconcat ("invalid object type `", g_type_name (G_TYPE_FROM_INSTANCE (object)), "' for value type `", G_VALUE_TYPE_NAME (value), "'", NULL);
		}
		value->data[0].v_pointer = ucn_plugin_module_manager_ref (object);
	} else {
		value->data[0].v_pointer = NULL;
	}
	return NULL;
}


static gchar* ucn_value_plugin_module_manager_lcopy_value (const GValue* value, guint n_collect_values, GTypeCValue* collect_values, guint collect_flags) {
	UCNPluginModuleManager** object_p;
	object_p = collect_values[0].v_pointer;
	if (!object_p) {
		return g_strdup_printf ("value location for `%s' passed as NULL", G_VALUE_TYPE_NAME (value));
	}
	if (!value->data[0].v_pointer) {
		*object_p = NULL;
	} else if (collect_flags && G_VALUE_NOCOPY_CONTENTS) {
		*object_p = value->data[0].v_pointer;
	} else {
		*object_p = ucn_plugin_module_manager_ref (value->data[0].v_pointer);
	}
	return NULL;
}


GParamSpec* ucn_param_spec_plugin_module_manager (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags) {
	UCNParamSpecPluginModuleManager* spec;
	g_return_val_if_fail (g_type_is_a (object_type, UCN_TYPE_PLUGIN_MODULE_MANAGER), NULL);
	spec = g_param_spec_internal (G_TYPE_PARAM_OBJECT, name, nick, blurb, flags);
	G_PARAM_SPEC (spec)->value_type = object_type;
	return G_PARAM_SPEC (spec);
}


gpointer ucn_value_get_plugin_module_manager (const GValue* value) {
	g_return_val_if_fail (G_TYPE_CHECK_VALUE_TYPE (value, UCN_TYPE_PLUGIN_MODULE_MANAGER), NULL);
	return value->data[0].v_pointer;
}


void ucn_value_set_plugin_module_manager (GValue* value, gpointer v_object) {
	UCNPluginModuleManager* old;
	g_return_if_fail (G_TYPE_CHECK_VALUE_TYPE (value, UCN_TYPE_PLUGIN_MODULE_MANAGER));
	old = value->data[0].v_pointer;
	if (v_object) {
		g_return_if_fail (G_TYPE_CHECK_INSTANCE_TYPE (v_object, UCN_TYPE_PLUGIN_MODULE_MANAGER));
		g_return_if_fail (g_value_type_compatible (G_TYPE_FROM_INSTANCE (v_object), G_VALUE_TYPE (value)));
		value->data[0].v_pointer = v_object;
		ucn_plugin_module_manager_ref (value->data[0].v_pointer);
	} else {
		value->data[0].v_pointer = NULL;
	}
	if (old) {
		ucn_plugin_module_manager_unref (old);
	}
}


static void ucn_plugin_module_manager_class_init (UCNPluginModuleManagerClass * klass) {
	ucn_plugin_module_manager_parent_class = g_type_class_peek_parent (klass);
	UCN_PLUGIN_MODULE_MANAGER_CLASS (klass)->finalize = ucn_plugin_module_manager_finalize;
	g_type_class_add_private (klass, sizeof (UCNPluginModuleManagerPrivate));
}


static void ucn_plugin_module_manager_instance_init (UCNPluginModuleManager * self) {
	self->priv = UCN_PLUGIN_MODULE_MANAGER_GET_PRIVATE (self);
	self->ref_count = 1;
}


static void ucn_plugin_module_manager_finalize (UCNPluginModuleManager* obj) {
	UCNPluginModuleManager * self;
	self = UCN_PLUGIN_MODULE_MANAGER (obj);
	(self->priv->modules == NULL) ? NULL : (self->priv->modules = (_g_list_free_g_object_unref (self->priv->modules), NULL));
}


static GType ucn_plugin_module_manager_type_id = 0;
GType ucn_plugin_module_manager_get_type (void) {
	return ucn_plugin_module_manager_type_id;
}


GType ucn_plugin_module_manager_register_type (GTypeModule * module) {
	static const GTypeValueTable g_define_type_value_table = { ucn_value_plugin_module_manager_init, ucn_value_plugin_module_manager_free_value, ucn_value_plugin_module_manager_copy_value, ucn_value_plugin_module_manager_peek_pointer, "p", ucn_value_plugin_module_manager_collect_value, "p", ucn_value_plugin_module_manager_lcopy_value };
	static const GTypeInfo g_define_type_info = { sizeof (UCNPluginModuleManagerClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) ucn_plugin_module_manager_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (UCNPluginModuleManager), 0, (GInstanceInitFunc) ucn_plugin_module_manager_instance_init, &g_define_type_value_table };
	static const GTypeFundamentalInfo g_define_type_fundamental_info = { (G_TYPE_FLAG_CLASSED | G_TYPE_FLAG_INSTANTIATABLE | G_TYPE_FLAG_DERIVABLE | G_TYPE_FLAG_DEEP_DERIVABLE) };
	ucn_plugin_module_manager_type_id = g_type_register_fundamental (g_type_fundamental_next (), "UCNPluginModuleManager", &g_define_type_info, &g_define_type_fundamental_info, 0);
	return ucn_plugin_module_manager_type_id;
}


gpointer ucn_plugin_module_manager_ref (gpointer instance) {
	UCNPluginModuleManager* self;
	self = instance;
	g_atomic_int_inc (&self->ref_count);
	return instance;
}


void ucn_plugin_module_manager_unref (gpointer instance) {
	UCNPluginModuleManager* self;
	self = instance;
	if (g_atomic_int_dec_and_test (&self->ref_count)) {
		UCN_PLUGIN_MODULE_MANAGER_GET_CLASS (self)->finalize (self);
		g_type_free_instance ((GTypeInstance *) self);
	}
}




