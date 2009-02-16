/* GTK - The GIMP Toolkit
 * Copyright (C) 2006-2007 Async Open Source,
 *                         Johan Dahlin <jdahlin@async.com.br>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef __UCN_BUILDER_H__
#define __UCN_BUILDER_H__

#include <glib-object.h>

G_BEGIN_DECLS

#define UCN_TYPE_BUILDER                 (ucn_builder_get_type ())
#define UCN_BUILDER(obj)                 (G_TYPE_CHECK_INSTANCE_CAST ((obj), UCN_TYPE_BUILDER, UCNBuilder))
#define UCN_BUILDER_CLASS(klass)         (G_TYPE_CHECK_CLASS_CAST ((klass), UCN_TYPE_BUILDER, UCNBuilderClass))
#define UCN_IS_BUILDER(obj)              (G_TYPE_CHECK_INSTANCE_TYPE ((obj), UCN_TYPE_BUILDER))
#define UCN_IS_BUILDER_CLASS(klass)      (G_TYPE_CHECK_CLASS_TYPE ((klass), UCN_TYPE_BUILDER))
#define UCN_BUILDER_GET_CLASS(obj)       (G_TYPE_INSTANCE_GET_CLASS ((obj), UCN_TYPE_BUILDER, UCNBuilderClass))

#define UCN_BUILDER_ERROR                (ucn_builder_error_quark ())

typedef struct _UCNBuilder        UCNBuilder;
typedef struct _UCNBuilderClass   UCNBuilderClass;
typedef struct _UCNBuilderPrivate UCNBuilderPrivate;

typedef enum
{
  UCN_BUILDER_ERROR_INVALID_TYPE_FUNCTION,
  UCN_BUILDER_ERROR_UNHANDLED_TAG,
  UCN_BUILDER_ERROR_MISSING_ATTRIBUTE,
  UCN_BUILDER_ERROR_INVALID_ATTRIBUTE,
  UCN_BUILDER_ERROR_INVALID_TAG,
  UCN_BUILDER_ERROR_MISSING_PROPERTY_VALUE,
  UCN_BUILDER_ERROR_INVALID_VALUE,
  UCN_BUILDER_ERROR_VERSION_MISMATCH
} UCNBuilderError;

GQuark ucn_builder_error_quark (void);

struct _UCNBuilder
{
  GObject parent_instance;

  UCNBuilderPrivate * priv;
};

struct _UCNBuilderClass
{
  GObjectClass parent_class;
  
  GType (* get_type_from_name) (UCNBuilder *builder,
                                const char *type_name);

  /* Padding for future expansion */
  void (*_ucn_reserved1) (void);
  void (*_ucn_reserved2) (void);
  void (*_ucn_reserved3) (void);
  void (*_ucn_reserved4) (void);
  void (*_ucn_reserved5) (void);
  void (*_ucn_reserved6) (void);
  void (*_ucn_reserved7) (void);
  void (*_ucn_reserved8) (void);
};

typedef void (*UCNBuilderConnectFunc) (UCNBuilder    *builder,
				       GObject       *object,
				       const gchar   *signal_name,
				       const gchar   *handler_name,
				       GObject       *connect_object,
				       GConnectFlags  flags,
				       gpointer       user_data);

GType        ucn_builder_get_type                (void) G_GNUC_CONST;
UCNBuilder*  ucn_builder_new                     (void);

guint        ucn_builder_add_from_file           (UCNBuilder    *builder,
                                                  const gchar   *filename,
                                                  GError       **error);
guint        ucn_builder_add_from_string         (UCNBuilder    *builder,
                                                  const gchar   *buffer,
                                                  gsize          length,
                                                  GError       **error);
guint        ucn_builder_add_objects_from_file   (UCNBuilder    *builder,
                                                  const gchar   *filename,
                                                  gchar        **object_ids,
                                                  GError       **error);
guint        ucn_builder_add_objects_from_string (UCNBuilder    *builder,
                                                  const gchar   *buffer,
                                                  gsize          length,
                                                  gchar        **object_ids,
                                                  GError       **error);
GObject*     ucn_builder_get_object              (UCNBuilder    *builder,
                                                  const gchar   *name);
GSList*      ucn_builder_get_objects             (UCNBuilder    *builder);
void         ucn_builder_connect_signals         (UCNBuilder    *builder,
						  gpointer       user_data);
void         ucn_builder_connect_signals_full    (UCNBuilder    *builder,
                                                  UCNBuilderConnectFunc func,
						  gpointer       user_data);
void         ucn_builder_set_translation_domain  (UCNBuilder   	*builder,
                                                  const gchar  	*domain);
const gchar* ucn_builder_get_translation_domain  (UCNBuilder   	*builder);
GType        ucn_builder_get_type_from_name      (UCNBuilder   	*builder,
                                                  const char   	*type_name);

gboolean     ucn_builder_value_from_string       (UCNBuilder    *builder,
						  GParamSpec   	*pspec,
                                                  const gchar  	*string,
                                                  GValue       	*value,
						  GError       **error);
gboolean     ucn_builder_value_from_string_type  (UCNBuilder    *builder,
						  GType        	 type,
                                                  const gchar  	*string,
                                                  GValue       	*value,
						  GError       **error);

#define UCN_BUILDER_WARN_INVALID_CHILD_TYPE(object, type) \
  g_warning ("'%s' is not a valid child type of '%s'", type, g_type_name (G_OBJECT_TYPE (object)))

G_END_DECLS

#endif /* __UCN_BUILDER_H__ */
